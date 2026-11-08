pluginManagement {
    fun findFlutterSdkOnPath(): String? {
        val isWindows = System.getProperty("os.name").lowercase().startsWith("windows")
        val names = if (isWindows) listOf("flutter.bat", "flutter.cmd", "flutter") else listOf("flutter")
        val sep = if (isWindows) ";" else ":"
        return System.getenv("PATH")
            ?.split(sep)
            ?.asSequence()
            ?.mapNotNull { dir -> names.map { java.io.File(dir, it) }.firstOrNull { it.isFile } }
            ?.mapNotNull { it.canonicalFile.parentFile?.parentFile }
            ?.firstOrNull { java.io.File(it, "packages/flutter_tools/gradle").isDirectory }
            ?.absolutePath
    }

    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localProperties = file("local.properties")
            if (localProperties.exists()) {
                localProperties.inputStream().use { properties.load(it) }
            }
            properties.getProperty("flutter.sdk")
                ?: System.getenv("FLUTTER_ROOT")
                ?: findFlutterSdkOnPath()
                ?: error(
                    "Flutter SDK not found. Set flutter.sdk in android/local.properties " +
                        "or the FLUTTER_ROOT environment variable."
                )
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    settings.extensions.extraProperties.set("flutterSdkPath", flutterSdkPath)

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    // Reads android/app/google-services.json and generates the Firebase config
    id("com.google.gms.google-services") version "4.5.0" apply false
}

val resolvedFlutterSdkPath = extensions.extraProperties.get("flutterSdkPath") as String

gradle.beforeProject {
    if (findProperty("flutter.sdk") == null) {
        extensions.extraProperties.set("flutter.sdk", resolvedFlutterSdkPath)
    }
}

include(":app")
