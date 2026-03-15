#!/usr/bin/env python3
"""
Generate Osakesaastajat.xcodeproj/project.pbxproj and supporting files.
Run from the osakesaastajat-app directory.
"""

import os
import uuid

# ── Config ──────────────────────────────────────────────────────────────────
APP       = "Osakesaastajat"
BUNDLE_ID = "com.osakesaastajat.app"
TEAM_ID   = ""  # Set your Apple Developer Team ID here
DEPLOY    = "16.0"
SWIFT_V   = "5"          # Use Swift 5 language mode (avoids Swift 6 strict concurrency)

SWIFT_FILES = [
    "OsakesaastajatApp.swift",
    "ContentView.swift",
    "GameModel.swift",
    "GameCenterManager.swift",
    "TitleView.swift",
    "SetupView.swift",
    "BuyView.swift",
    "SellView.swift",
    "DividendView.swift",
    "PriceEventView.swift",
    "AskQuitView.swift",
    "EndGameView.swift",
]

# ── UUID helpers ─────────────────────────────────────────────────────────────
def uid():
    return uuid.uuid4().hex[:24].upper()

# Pre-generate all IDs
P = {k: uid() for k in [
    "project", "target",
    "sources_phase", "frameworks_phase", "resources_phase",
    "main_group", "products_group", "app_group",
    "app_product_ref",
    "assets_ref", "assets_build",
    "gk_ref", "gk_build",
    "entitlements_ref",
    "debug_target", "release_target",
    "debug_project", "release_project",
    "target_config_list", "project_config_list",
]}
file_refs  = {f: uid() for f in SWIFT_FILES}
build_ids  = {f: uid() for f in SWIFT_FILES}

# ── project.pbxproj ─────────────────────────────────────────────────────────
def build_files_section():
    lines = []
    for f in SWIFT_FILES:
        lines.append(f'\t\t{build_ids[f]} /* {f} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[f]} /* {f} */; }};')
    lines.append(f'\t\t{P["assets_build"]} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {P["assets_ref"]} /* Assets.xcassets */; }};')
    lines.append(f'\t\t{P["gk_build"]} /* GameKit.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {P["gk_ref"]} /* GameKit.framework */; }};')
    return "\n".join(lines)

def file_refs_section():
    lines = []
    for f in SWIFT_FILES:
        lines.append(f'\t\t{file_refs[f]} /* {f} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {f}; sourceTree = "<group>"; }};')
    lines += [
        f'\t\t{P["assets_ref"]} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};',
        f'\t\t{P["entitlements_ref"]} /* {APP}.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = {APP}.entitlements; sourceTree = "<group>"; }};',
        f'\t\t{P["app_product_ref"]} /* {APP}.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = {APP}.app; sourceTree = BUILT_PRODUCTS_DIR; }};',
        f'\t\t{P["gk_ref"]} /* GameKit.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = GameKit.framework; path = System/Library/Frameworks/GameKit.framework; sourceTree = SDKROOT; }};',
    ]
    return "\n".join(lines)

def source_build_files():
    return ",\n\t\t\t\t".join(
        f'{build_ids[f]} /* {f} in Sources */'
        for f in SWIFT_FILES
    )

def app_group_children():
    children = [f'{file_refs[f]} /* {f} */' for f in SWIFT_FILES]
    children += [
        f'{P["assets_ref"]} /* Assets.xcassets */',
        f'{P["entitlements_ref"]} /* {APP}.entitlements */',
    ]
    return ",\n\t\t\t\t".join(children)

def build_config(cfg_id, is_debug, is_target):
    name = "Debug" if is_debug else "Release"
    opt  = "0" if is_debug else "s"
    enable_testability = "YES" if is_debug else "NO"

    common = f"""
\t\t{cfg_id} /* {name} */ = {{
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {{"""

    if is_target:
        common += f"""
\t\t\t\tASPRUNTIME_VERSION = 2;
\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
\t\t\t\tCODE_SIGN_ENTITLEMENTS = {APP}.entitlements;
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tDEVELOPMENT_TEAM = {TEAM_ID};
\t\t\t\tENABLE_PREVIEWS = YES;
\t\t\t\tGENERATE_INFOPLIST_FILE = YES;
\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = {APP};
\t\t\t\tINFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
\t\t\t\tINFOPLIST_KEY_UIRequiresFullScreen = NO;
\t\t\t\tINFOPLIST_KEY_UIStatusBarHidden = NO;
\t\t\t\tINFOPLIST_KEY_UIStatusBarStyle = UIStatusBarStyleLightContent;
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
\t\t\t\tINFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOY};
\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = {BUNDLE_ID};
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;
\t\t\t\tSWIFT_VERSION = {SWIFT_V};
\t\t\t\tTARGETED_DEVICE_FAMILY = "1,2";"""
    else:
        common += f"""
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = {"dwarf" if is_debug else "dwarf-with-dsym"};
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = {enable_testability};
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = {opt};
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ({'"DEBUG=1", ' if is_debug else ""}"$(inherited)", );
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = {DEPLOY};
\t\t\t\tMTL_ENABLE_DEBUG_INFO = {"INCLUDE_SOURCE" if is_debug else "NO"};
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = {"YES" if is_debug else "NO"};
\t\t\t\tSDKROOT = iphoneos;"""
    if is_debug:
        common += """
\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;"""

    common += """
\t\t\t};
\t\t\tname = """ + name + """;
\t\t};"""
    return common

# ── Assemble pbxproj ─────────────────────────────────────────────────────────
pbxproj = f"""// !$*UTF8*$!
{{
\tarchiveVersion = 1;
\tclasses = {{
\t}};
\tobjectVersion = 77;
\tobjects = {{

/* Begin PBXBuildFile section */
{build_files_section()}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{file_refs_section()}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t{P["frameworks_phase"]} /* Frameworks */ = {{
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{P["gk_build"]} /* GameKit.framework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t{P["main_group"]} = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{P["app_group"]} /* {APP} */,
\t\t\t\t{P["products_group"]} /* Products */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{P["products_group"]} /* Products */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{P["app_product_ref"]} /* {APP}.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t}};
\t\t{P["app_group"]} /* {APP} */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t{app_group_children()},
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t{P["target"]} /* {APP} */ = {{
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = {P["target_config_list"]} /* Build configuration list for PBXNativeTarget "{APP}" */;
\t\t\tbuildPhases = (
\t\t\t\t{P["sources_phase"]} /* Sources */,
\t\t\t\t{P["frameworks_phase"]} /* Frameworks */,
\t\t\t\t{P["resources_phase"]} /* Resources */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = {APP};
\t\t\tproductName = {APP};
\t\t\tproductReference = {P["app_product_ref"]} /* {APP}.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t{P["project"]} /* Project object */ = {{
\t\t\tisa = PBXProject;
\t\t\tattributes = {{
\t\t\t\tBuildIndependentTargetsInParallel = 1;
\t\t\t\tLastSwiftUpdateCheck = 1620;
\t\t\t\tLastUpgradeCheck = 1620;
\t\t\t\tTargetAttributes = {{
\t\t\t\t\t{P["target"]} = {{
\t\t\t\t\t\tCreatedOnToolsVersion = 16.2;
\t\t\t\t\t\tDevelopmentTeam = {TEAM_ID};
\t\t\t\t\t}};
\t\t\t\t}};
\t\t\t}};
\t\t\tbuildConfigurationList = {P["project_config_list"]} /* Build configuration list for PBXProject "{APP}" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = {P["main_group"]};
\t\t\tproductRefGroup = {P["products_group"]} /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t{P["target"]} /* {APP} */,
\t\t\t);
\t\t}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t{P["resources_phase"]} /* Resources */ = {{
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{P["assets_build"]} /* Assets.xcassets in Resources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t{P["sources_phase"]} /* Sources */ = {{
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t{source_build_files()},
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
{build_config(P["debug_target"],   is_debug=True,  is_target=True)}
{build_config(P["release_target"], is_debug=False, is_target=True)}
{build_config(P["debug_project"],  is_debug=True,  is_target=False)}
{build_config(P["release_project"],is_debug=False, is_target=False)}
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t{P["target_config_list"]} /* Build configuration list for PBXNativeTarget "{APP}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{P["debug_target"]} /* Debug */,
\t\t\t\t{P["release_target"]} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
\t\t{P["project_config_list"]} /* Build configuration list for PBXProject "{APP}" */ = {{
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t{P["debug_project"]} /* Debug */,
\t\t\t\t{P["release_project"]} /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Release;
\t\t}};
/* End XCConfigurationList section */
\t}};
\trootObject = {P["project"]} /* Project object */;
}}
"""

# ── Scheme file ──────────────────────────────────────────────────────────────
scheme = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1620"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{P["target"]}"
               BuildableName = "{APP}.app"
               BlueprintName = "{APP}"
               ReferencedContainer = "container:{APP}.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{P["target"]}"
            BuildableName = "{APP}.app"
            BlueprintName = "{APP}"
            ReferencedContainer = "container:{APP}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{P["target"]}"
            BuildableName = "{APP}.app"
            BlueprintName = "{APP}"
            ReferencedContainer = "container:{APP}.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""

# ── Assets.xcassets ──────────────────────────────────────────────────────────
assets_contents = '{"info":{"author":"xcode","version":1}}'
appicon_contents = '''{
  "images": [
    {"idiom":"universal","platform":"ios","size":"1024x1024","scale":"1x","filename":"AppIcon.png"}
  ],
  "info":{"author":"xcode","version":1}
}'''
accent_contents = '''{
  "colors":[{"color":{"color-space":"srgb","components":{"alpha":"1.000","blue":"0.549","green":"0.000","red":"0.000"}},"idiom":"universal"}],
  "info":{"author":"xcode","version":1}
}'''

# ── Entitlements ─────────────────────────────────────────────────────────────
entitlements = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
\t<key>com.apple.developer.game-center</key>
\t<true/>
</dict>
</plist>
"""

# ── Write files ──────────────────────────────────────────────────────────────
proj_dir  = f"{APP}.xcodeproj"
scheme_dir = f"{proj_dir}/xcshareddata/xcschemes"

os.makedirs(proj_dir,  exist_ok=True)
os.makedirs(scheme_dir, exist_ok=True)
os.makedirs("Assets.xcassets/AppIcon.appiconset",   exist_ok=True)
os.makedirs("Assets.xcassets/AccentColor.colorset", exist_ok=True)

with open(f"{proj_dir}/project.pbxproj", "w") as f:
    f.write(pbxproj)
print(f"✓ {proj_dir}/project.pbxproj")

with open(f"{scheme_dir}/{APP}.xcscheme", "w") as f:
    f.write(scheme)
print(f"✓ {scheme_dir}/{APP}.xcscheme")

with open("Assets.xcassets/Contents.json", "w") as f:
    f.write(assets_contents)
with open("Assets.xcassets/AppIcon.appiconset/Contents.json", "w") as f:
    f.write(appicon_contents)
with open("Assets.xcassets/AccentColor.colorset/Contents.json", "w") as f:
    f.write(accent_contents)
print("✓ Assets.xcassets")

with open(f"{APP}.entitlements", "w") as f:
    f.write(entitlements)
print(f"✓ {APP}.entitlements")

print(f"\nProject generated: {proj_dir}")
print(f"Team:   {TEAM_ID}")
print(f"Bundle: {BUNDLE_ID}")
