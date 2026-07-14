import 'package:cosmox_client/core/state.dart';
import 'package:cosmox_client/src/rust/api/cosmox.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Singleton proxy around [CosmoxSdk].
///
/// Catches [SdkError] variants and routes them to the right provider:
///   - [SdkError_Unauthenticated] → [AuthController.triggerSessionExpired]
///   - [SdkError_ConnectionFailed] → [AuthController.triggerServerLost]
/// Other errors are rethrown so callers can handle UI state.
class SdkProxy {
  static final SdkProxy _instance = SdkProxy._internal();
  static SdkProxy get instance => _instance;
  factory SdkProxy() => _instance;
  SdkProxy._internal();

  /// Cosmox sdk
  late final CosmoxSdk _cosmox;

  T _sync<T>(T Function() fn) {
    try {
      return fn();
    } on SdkError_Unauthenticated {
      AuthController.instance.triggerSessionExpired();
      rethrow;
    } on SdkError_ConnectionFailed {
      AuthController.instance.triggerServerLost();
      rethrow;
    }
  }

  Future<void> _void(Future<void> Function() fn) async {
    try {
      await fn();
    } on SdkError_Unauthenticated {
      AuthController.instance.triggerSessionExpired();
      rethrow;
    } on SdkError_ConnectionFailed {
      AuthController.instance.triggerServerLost();
      rethrow;
    }
  }

  Future<T> _value<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on SdkError_Unauthenticated {
      AuthController.instance.triggerSessionExpired();
      rethrow;
    } on SdkError_ConnectionFailed {
      AuthController.instance.triggerServerLost();
      rethrow;
    }
  }

  void init({required String hostname, required int port}) =>
      _cosmox = CosmoxSdk(hostname: hostname, port: port);

  void setToken({required String token}) =>
      _sync(() => _cosmox.setToken(token: token));

  String? getToken() => _sync(() => _cosmox.getToken());

  Future<SystemInfo> systemInfo() => _value(() => _cosmox.systemInfo());

  Future<void> systemRestart() => _void(() => _cosmox.systemRestart());

  Future<void> systemShutdown() => _void(() => _cosmox.systemShutdown());

  Future<String> systemLog() => _value(() => _cosmox.systemLog());

  Future<String> systemAbout() => _value(() => _cosmox.systemAbout());

  Future<InitStatus> initialize({
    required String adminPassword,
    required String confirmPassword,
  }) => _value(
    () => _cosmox.initialize(
      adminPassword: adminPassword,
      confirmPassword: confirmPassword,
    ),
  );

  Future<String?> login({required String username, required String password}) =>
      _value(() => _cosmox.login(username: username, password: password));

  Future<List<User>> userQuery() => _value(() => _cosmox.userQuery());

  Future<User> userGet({required BigInt uid}) =>
      _value(() => _cosmox.userGet(uid: uid));

  Future<User> userSelf() => _value(() => _cosmox.userSelf());

  Future<UserResp> userRegister({
    required String username,
    required String password,
    required String confirmPassword,
  }) => _value(
    () => _cosmox.userRegister(
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    ),
  );

  Future<UserResp> userRegisterWithProfile({
    required String username,
    required String password,
    required String confirmPassword,
    String? nickname,
    String? email,
  }) => _value(
    () => _cosmox.userRegisterWithProfile(
      username: username,
      password: password,
      confirmPassword: confirmPassword,
      nickname: nickname,
      email: email,
    ),
  );

  Future<List<Library>> libraryQuery() => _value(() => _cosmox.libraryQuery());

  Future<Library> libraryGet({required BigInt lid}) =>
      _value(() => _cosmox.libraryGet(lid: lid));

  Future<List<LibraryType>> libraryTypes() =>
      _value(() => _cosmox.libraryTypes());

  Future<(Library, List<LibrariesRelatedTags>, List<LibraryPath>)> libraryAdd({
    required String name,
    String? description,
    required BigInt typeId,
    required Uint64List tags,
    required List<String> libraryPaths,
  }) => _value(
    () => _cosmox.libraryAdd(
      name: name,
      description: description,
      typeId: typeId,
      tags: tags,
      libraryPaths: libraryPaths,
    ),
  );

  Future<ScannerInfo> scannerInfo() => _value(() => _cosmox.scannerInfo());

  Future<String> scannerScan({required BigInt lid}) =>
      _value(() => _cosmox.scannerScan(lid: lid));

  Future<String> scannerScanAll() => _value(() => _cosmox.scannerScanAll());

  Future<ScannerStatus> scannerStatus() =>
      _value(() => _cosmox.scannerStatus());

  Future<List<Resource>> resourceQuery({required BigInt lid}) =>
      _value(() => _cosmox.resourceQuery(lid: lid));

  Future<Resource> resourceGet({required BigInt rid}) =>
      _value(() => _cosmox.resourceGet(rid: rid));

  Future<List<TagCatalogEntry>> tagCatalog() =>
      _value(() => _cosmox.tagCatalog());

  Future<List<TagGroup>> tagGroupQuery() =>
      _value(() => _cosmox.tagGroupQuery());

  Future<List<Tag>> tagQuery() => _value(() => _cosmox.tagQuery());

  Future<void> systemDeleteAll() => _void(() => _cosmox.systemDeleteAll());

  Future<void> userDelete({required BigInt uid}) =>
      _void(() => _cosmox.userDelete(uid: uid));

  Future<void> userRoleAdd({required BigInt uid, required BigInt rid}) =>
      _void(() => _cosmox.userRoleAdd(uid: uid, rid: rid));

  Future<PushResponse> userUploadAvatar({
    required BigInt uid,
    required Uint8List data,
  }) => _value(() => _cosmox.userUploadAvatar(uid: uid, data: data));

  Future<void> libraryModify({
    required BigInt lid,
    String? name,
    String? description,
  }) => _void(
    () => _cosmox.libraryModify(lid: lid, name: name, description: description),
  );

  Future<void> libraryDelete({required BigInt lid}) =>
      _void(() => _cosmox.libraryDelete(lid: lid));

  Future<String> resourceAdd({
    required String name,
    required BigInt lid,
    String? description,
    required BigInt level,
  }) => _value(
    () => _cosmox.resourceAdd(
      name: name,
      lid: lid,
      description: description,
      level: level,
    ),
  );

  Future<void> resourceDelete({required BigInt rid}) =>
      _void(() => _cosmox.resourceDelete(rid: rid));

  Future<String> resourceAddTag({
    required BigInt rid,
    required Uint64List tagIds,
  }) => _value(() => _cosmox.resourceAddTag(rid: rid, tagIds: tagIds));

  Future<Tag> tagGet({required BigInt tid}) =>
      _value(() => _cosmox.tagGet(tid: tid));

  Future<BigInt> tagAdd({required String label, required BigInt tgid}) =>
      _value(() => _cosmox.tagAdd(label: label, tgid: tgid));

  Future<TagGroup> tagGroupGet({required BigInt tgid}) =>
      _value(() => _cosmox.tagGroupGet(tgid: tgid));

  Future<BigInt> tagGroupAdd({required String label}) =>
      _value(() => _cosmox.tagGroupAdd(label: label));

  Future<void> tagGroupDelete({required BigInt tgid}) =>
      _void(() => _cosmox.tagGroupDelete(tgid: tgid));

  Future<List<String>> pathSubPath({
    required String path,
    required bool showHide,
  }) => _value(() => _cosmox.pathSubPath(path: path, showHide: showHide));

  Future<String> metadataQuery({
    required BigInt rootNode,
    required BigInt depth,
  }) => _value(() => _cosmox.metadataQuery(rootNode: rootNode, depth: depth));

  Future<String> search({
    required String keyword,
    List<String>? tags,
    BigInt? lid,
    String? beforeCreateDatetime,
    String? afterCreateDatetime,
    String? beforeLastUpdateDatetime,
    String? afterLastUpdateDatetime,
  }) => _value(
    () => _cosmox.search(
      keyword: keyword,
      tags: tags,
      lid: lid,
      beforeCreateDatetime: beforeCreateDatetime,
      afterCreateDatetime: afterCreateDatetime,
      beforeLastUpdateDatetime: beforeLastUpdateDatetime,
      afterLastUpdateDatetime: afterLastUpdateDatetime,
    ),
  );

  Future<PushResponse> itemPush({required Uint8List data}) =>
      _value(() => _cosmox.itemPush(data: data));

  Future<String> itemPull({required BigInt id}) =>
      _value(() => _cosmox.itemPull(id: id));

  String staticItem({required String path}) => _cosmox.staticItem(path: path);

  void logout() => _sync(() => _cosmox.logout());

  Future<String> resourceGetMetadata({required BigInt rid}) =>
      _value(() => _cosmox.resourceGetMetadata(rid: rid));

  Future<String> metadataGet({required BigInt mid}) =>
      _value(() => _cosmox.metadataGet(mid: mid));

  Future<String> openapi() => _value(() => _cosmox.openapi());

  Future<String> docs() => _value(() => _cosmox.docs());

  Future<String> pluginInfo() => _value(() => _cosmox.pluginInfo());

  Future<List<PluginQueryItem>> pluginQuery({
    String? name,
    String? status,
    String? pluginType,
  }) => _value(
    () =>
        _cosmox.pluginQuery(name: name, status: status, pluginType: pluginType),
  );

  Future<String> pluginInstall({String? url}) =>
      _value(() => _cosmox.pluginInstall(url: url));

  Future<void> pluginUninstall({required String name}) =>
      _void(() => _cosmox.pluginUninstall(name: name));

  Future<void> pluginEnable({required String name}) =>
      _void(() => _cosmox.pluginEnable(name: name));

  Future<void> pluginDisable({required String name}) =>
      _void(() => _cosmox.pluginDisable(name: name));

  Future<List<Role>> aclQueryRole() => _value(() => _cosmox.aclQueryRole());

  Future<List<Permission>> aclQueryPermission() =>
      _value(() => _cosmox.aclQueryPermission());

  Future<void> aclAddRole({required String name, String? description}) =>
      _void(() => _cosmox.aclAddRole(name: name, description: description));

  Future<void> aclDeleteRole({required BigInt rid}) =>
      _void(() => _cosmox.aclDeleteRole(rid: rid));

  Future<void> aclAddPermission({required String name, String? description}) =>
      _void(
        () => _cosmox.aclAddPermission(name: name, description: description),
      );

  Future<void> aclDeletePermission({required BigInt pid}) =>
      _void(() => _cosmox.aclDeletePermission(pid: pid));

  Future<void> aclAddPermissionForRole({
    required BigInt rid,
    required BigInt pid,
  }) => _void(() => _cosmox.aclAddPermissionForRole(rid: rid, pid: pid));

  Future<void> scannerAddTask({BigInt? lid, bool? fullScan}) =>
      _void(() => _cosmox.scannerAddTask(lid: lid, fullScan: fullScan));
}
