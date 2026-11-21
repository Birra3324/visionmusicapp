import 'package:flutter_test/flutter_test.dart';
import 'package:visionmusicapp/core/services/song_id_aliases.dart';

void main() {
  const cdn = {'yosan-getahun-3obsa', 'andualem-gosa-gumgume', 'shukri-jamal-marartuu'};
  const bundled = {'yosan_getahun', 'andualem_gosa', 'shagoye'};

  test('old bundled favorites map onto CDN songs', () {
    expect(
      resolveSongIds(['shagoye', 'yosan_getahun'], cdn),
      ['shukri-jamal-marartuu', 'yosan-getahun-3obsa'],
    );
  });

  test('CDN favorites map back when only bundled songs are loaded', () {
    expect(resolveSongId('andualem-gosa-gumgume', bundled), 'andualem_gosa');
  });

  test('ids already in the catalog and unknown ids are unchanged', () {
    expect(resolveSongId('yosan-getahun-3obsa', cdn), 'yosan-getahun-3obsa');
    expect(resolveSongId('something-else', cdn), 'something-else');
  });

  test('an old and a new id for the same song collapse to one', () {
    expect(
      resolveSongIds(['yosan_getahun', 'yosan-getahun-3obsa'], cdn),
      ['yosan-getahun-3obsa'],
    );
  });
}
