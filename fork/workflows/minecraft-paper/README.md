# Paper plugin starter (external: Gradle, not a Craft Anything feature)

A minimal Paper server plugin with one command, `/hello`. It is a starting point for a requested
feature, not a finished plugin. It is for **Java Edition servers running Paper** (or Spigot-API
compatible servers); client mods (Fabric, NeoForge) and Bedrock are different projects.

1. Fill in `INTAKE.md`: the server's exact Minecraft version decides `gradle.properties`:
   - `paperApi`: the Paper API version for that Minecraft version (from repo.papermc.io);
   - `javaVersion`: 21 for 1.21.x. Paper's 26.x API is published for Java 25, which also needs a
     newer Gradle than this wrapper (8.14.3) can run on: update the wrapper first.
2. Install the matching JDK (e.g. `winget install EclipseAdoptium.Temurin.21.JDK`).
3. Build: `.\gradlew.bat build` (Windows) or `./gradlew build`. The plugin is
   `build/libs/hello-plugin-<version>.jar`. The wrapper downloads Gradle 8.14.3 once and checks it
   against the SHA-256 in `gradle/wrapper/gradle-wrapper.properties`.
4. Test on a **disposable** local server, never a live world: a new folder with that version's
   Paper server JAR, accept the EULA there yourself, copy the plugin into `plugins/`, start it,
   look for `HelloPlugin enabled` in the log, join on `localhost`, run `/hello`.

Verified so far: `gradle build` with Paper API 1.21.11-R0.1-SNAPSHOT on JDK 21 produced the JAR
(Java 21 class files, `plugin.yml` filled in). Not yet loaded on a server, and not built on
Windows. `gradle-wrapper.jar` is Gradle 8.14.3's own (SHA-256
7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172, as Gradle publishes it).
