allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define a custom build directory path
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Apply the custom build directory to all subprojects
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Make sure all subprojects depend on app evaluation (if needed)
subprojects {
    project.evaluationDependsOn(":app")
}

// Force androidx.core version globally (❌ no afterEvaluate!)
subprojects {
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core" && requested.name == "core") {
                useVersion("1.12.0")
                because("Force compatible androidx.core version to avoid duplicate class errors")
            }
        }
    }
}

// Register clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
