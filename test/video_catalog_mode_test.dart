import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/video_service.dart';
import 'package:visionmusicapp/mock_videos.dart';
import 'package:visionmusicapp/models/video.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unresponsive live reads have a bounded deadline', () async {
    final service = VideoService(
      firestore: _Firestore(hanging: true),
      useFirebase: true,
      allowLocalFallback: false,
      requestTimeout: const Duration(milliseconds: 20),
    );
    await expectLater(
      service.fetchAllVideos(),
      throwsA(isA<TimeoutException>()),
    );
    await expectLater(
      service.fetchFeaturedVideos(),
      throwsA(isA<TimeoutException>()),
    );
    await expectLater(
      service.fetchVideoCategories(),
      throwsA(isA<TimeoutException>()),
    );
    await expectLater(
      service.fetchVideosByCategory('music_videos'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('grouping categories reads the video collection only once', () async {
    final firestore = _Firestore();
    final service = VideoService(
      firestore: firestore,
      useFirebase: true,
      allowLocalFallback: false,
    );
    await service.fetchVideosByAllCategories(kDefaultVideoCategories);
    expect(firestore.queryReads, 1);
  });

  test('local video mode never contacts Firestore', () async {
    final firestore = _Firestore(error: StateError('must not be contacted'));
    final service = VideoService(firestore: firestore, useFirebase: false);
    expect(await service.fetchAllVideos(), mockVideos);
    expect(await service.fetchFeaturedVideos(), isNotEmpty);
    expect(await service.fetchVideoById(mockVideos.first.id), isNotNull);
    await service.incrementViewCount(mockVideos.first.id);
    expect(firestore.requests, 0);
  });

  test(
    'unavailable Firebase never substitutes demo videos in live mode',
    () async {
      final service = VideoService(
        useFirebase: true,
        allowLocalFallback: false,
      );
      expect(await service.fetchAllVideos(), isEmpty);
      expect(await service.fetchFeaturedVideos(), isEmpty);
      expect(await service.fetchVideosByCategory('music_videos'), isEmpty);
      expect(await service.fetchRelatedVideos(mockVideos.first), isEmpty);
      expect(await service.fetchVideoById(mockVideos.first.id), isNull);
    },
  );

  test('an empty live catalog stays empty across list queries', () async {
    final service = VideoService(
      firestore: _Firestore(),
      useFirebase: true,
      allowLocalFallback: false,
    );
    expect(await service.fetchAllVideos(), isEmpty);
    expect(await service.fetchFeaturedVideos(), isEmpty);
    expect(await service.fetchVideosByCategory('music_videos'), isEmpty);
  });

  test(
    'live query errors reach the retry UI instead of showing demo videos',
    () async {
      final failure = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
      );
      final service = VideoService(
        firestore: _Firestore(error: failure),
        useFirebase: true,
        allowLocalFallback: false,
      );
      await expectLater(service.fetchAllVideos(), throwsA(same(failure)));
      await expectLater(service.fetchFeaturedVideos(), throwsA(same(failure)));
      await expectLater(
        service.fetchVideosByCategory('music_videos'),
        throwsA(same(failure)),
      );
      await expectLater(service.fetchVideoCategories(), throwsA(same(failure)));
      await expectLater(
        service.fetchVideoById(mockVideos.first.id),
        throwsA(same(failure)),
      );
    },
  );

  test(
    'demo fallback works only when explicitly allowed in live mode',
    () async {
      for (final error in [null, StateError('network unavailable')]) {
        final service = VideoService(
          firestore: _Firestore(error: error),
          useFirebase: true,
          allowLocalFallback: true,
        );
        expect(await service.fetchAllVideos(), mockVideos);
        expect(await service.fetchFeaturedVideos(), isNotEmpty);
        expect(
          await service.fetchVideosByCategory(mockVideos.first.category),
          isNotEmpty,
        );
      }
    },
  );
}

// Deterministic Firestore transport doubles. Publication authorization is
// exercised separately against the actual Firestore rules in the emulator.
class _Firestore extends Fake implements FirebaseFirestore {
  final Object? error;
  int requests = 0;
  int queryReads = 0;
  final bool hanging;
  _Firestore({this.error, this.hanging = false});

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    requests++;
    return _Collection(error, hanging, () => queryReads++);
  }
}

// Test-only transport double; production code never subclasses Firestore Query.
// ignore: subtype_of_sealed_class
class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final Object? error;
  final bool hanging;
  final void Function() onRead;
  _Collection(this.error, this.hanging, this.onRead);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #where || invocation.memberName == #orderBy) {
      return this;
    }
    if (invocation.memberName == #doc) return _Document(error);
    if (invocation.memberName == #get) {
      onRead();
      if (hanging) {
        return Completer<QuerySnapshot<Map<String, dynamic>>>().future;
      }
      return error == null
          ? Future<QuerySnapshot<Map<String, dynamic>>>.value(_Snapshot())
          : Future<QuerySnapshot<Map<String, dynamic>>>.error(error!);
    }
    return super.noSuchMethod(invocation);
  }
}

class _Snapshot extends Fake implements QuerySnapshot<Map<String, dynamic>> {
  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => [];
}

// Test-only transport double used to simulate a rejected document read.
// ignore: subtype_of_sealed_class
class _Document extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  final Object? error;
  _Document(this.error);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    throw error ?? StateError('No document');
  }
}
