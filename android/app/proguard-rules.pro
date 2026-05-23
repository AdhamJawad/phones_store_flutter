# Placeholder for app-specific keep rules.
# Flutter and plugin defaults are provided through the Android Gradle plugin setup.

# Keep Dio generic response typing metadata where reflection-based debugging is used.
-keepattributes Signature

# Keep easy_localization generated assets references.
-keep class **.R$* { *; }
