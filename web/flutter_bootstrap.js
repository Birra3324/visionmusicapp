{{flutter_js}}
{{flutter_build_config}}

// Ship the renderer with the app so a blocked third-party CDN cannot blank it.
_flutter.loader.load({
  config: { canvasKitBaseUrl: 'canvaskit/' },
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      window.visionLoadingDone?.();
    } catch (error) {
      window.visionLoadingFailed?.();
      throw error;
    }
  }
}).catch(() => window.visionLoadingFailed?.());
