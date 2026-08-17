pub use cosmox_sdk::types::{
    DeviceQueryRequest, DeviceSession, InitStatus, LibrariesRelatedTags, Library, LibraryPath,
    LibraryQueryRequest, LibraryType, Metadata, MetadataType, Permission, PluginQueryItem,
    PushResponse, Resource, ResourceQueryRequest, Role, ScannerInfo, ScannerStatus, SearchRequest,
    SystemInfo, Tag, TagCatalogEntry, TagGroup, TagQueryRequest, User, UserLogin, UserLoginIdent,
    UserQueryRequest, UserResp,
};
use cosmox_sdk::{Api, HttpApi, create_client};
use reqwest::Url;
use std::collections::HashMap;

// ---------------------------------------------------------------------------
// FRB mirrors — tells codegen to generate Dart data classes for SDK types.
// ---------------------------------------------------------------------------

#[flutter_rust_bridge::frb(mirror(SystemInfo))]
pub struct _SystemInfo {
    pub os: String,
    pub name: String,
    pub version: String,
    pub author: String,
    pub is_first_boot: bool,
}

#[flutter_rust_bridge::frb(mirror(User))]
pub struct _User {
    pub uid: u64,
    pub username: String,
    pub email: Option<String>,
    pub nickname: Option<String>,
    pub avatar: Option<u64>,
    pub create_datetime: chrono::NaiveDateTime,
    pub last_update_datetime: chrono::NaiveDateTime,
}

#[flutter_rust_bridge::frb(mirror(Library))]
pub struct _Library {
    pub lid: u64,
    pub name: Option<String>,
    pub description: Option<String>,
    pub r#type: Option<u64>,
    pub create_by_uid: u64,
    pub create_datetime: chrono::NaiveDateTime,
    pub last_update_datetime: chrono::NaiveDateTime,
}

#[flutter_rust_bridge::frb(mirror(LibrariesRelatedTags))]
pub struct _LibrariesRelatedTags {
    pub lrtid: u64,
    pub lid: u64,
    pub tid: u64,
}

#[flutter_rust_bridge::frb(mirror(LibraryPath))]
pub struct _LibraryPath {
    pub lpid: u64,
    pub lid: u64,
    pub path: String,
}

#[flutter_rust_bridge::frb(mirror(LibraryType))]
pub struct _LibraryType {
    pub tid: u64,
    pub scan_mode: Option<String>,
    pub label: String,
}

#[flutter_rust_bridge::frb(mirror(Resource))]
pub struct _Resource {
    pub rid: u64,
    pub name: Option<String>,
    pub description: Option<String>,
    pub lid: Option<u64>,
    pub create_datetime: chrono::NaiveDateTime,
    pub last_update_datetime: chrono::NaiveDateTime,
    pub metadata_index: Option<u64>,
    pub cover: Option<u64>,
}

#[flutter_rust_bridge::frb(mirror(Tag))]
pub struct _Tag {
    pub tid: u64,
    pub name: String,
    pub tgid: u64,
    pub create_datetime: chrono::NaiveDateTime,
}

#[flutter_rust_bridge::frb(mirror(TagGroup))]
pub struct _TagGroup {
    pub tgid: u64,
    pub name: String,
    pub create_datetime: chrono::NaiveDateTime,
}

#[flutter_rust_bridge::frb(mirror(TagCatalogEntry))]
pub struct _TagCatalogEntry {
    pub group: TagGroup,
    pub tags: Vec<Tag>,
}

#[flutter_rust_bridge::frb(mirror(ScannerInfo))]
pub struct _ScannerInfo {
    pub available: bool,
    pub version: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(ScannerStatus))]
pub struct _ScannerStatus {
    pub scanning: bool,
    pub current_lid: Option<u64>,
}

#[flutter_rust_bridge::frb(mirror(UserResp))]
pub struct _UserResp {
    pub uid: u64,
    pub username: String,
    pub email: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(InitStatus))]
pub struct _InitStatus {
    pub initialized: bool,
}

#[flutter_rust_bridge::frb(mirror(PushResponse))]
pub struct _PushResponse {
    pub pmid: u64,
    pub uploaded_size: u64,
}

#[flutter_rust_bridge::frb(mirror(DeviceSession))]
pub struct _DeviceSession {
    pub did: u64,
    pub uid: Option<u64>,
    pub user_agent: Option<String>,
    pub last_login_datetime: chrono::NaiveDateTime,
    pub last_login_ip: String,
}

#[flutter_rust_bridge::frb(mirror(DeviceQueryRequest))]
pub struct _DeviceQueryRequest {
    pub uid: Option<u64>,
    pub sort: Option<String>,
    pub page: Option<u64>,
    pub page_size: u64,
}

#[flutter_rust_bridge::frb(mirror(PluginQueryItem))]
pub struct _PluginQueryItem {
    pub name: String,
    pub version: String,
    pub description: String,
    pub author: String,
    pub email: String,
    pub enabled: bool,
    pub plugin_type: String,
    pub error: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(Role))]
pub struct _Role {
    pub rid: u64,
    pub name: String,
    pub description: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(Permission))]
pub struct _Permission {
    pub pid: u64,
    pub name: String,
    pub description: Option<String>,
}

#[flutter_rust_bridge::frb(mirror(SearchRequest))]
pub struct _SearchRequest {
    pub keyword: String,
    pub tags: Option<Vec<String>>,
    pub lid: Option<u64>,
    pub before_create_datetime: Option<String>,
    pub after_create_datetime: Option<String>,
    pub before_last_update_datetime: Option<String>,
    pub after_last_update_datetime: Option<String>,
    pub sort: Option<String>,
    pub page: Option<u64>,
    pub page_size: u64,
}

pub type SdkError = cosmox_sdk::SdkError;

#[flutter_rust_bridge::frb(mirror(SdkError))]
pub enum _SdkError {
    Unauthenticated,
    ConnectionFailed(String),
    HttpError { status: i32, message: String },
    SerdeError(String),
    Internal(String),
}

#[flutter_rust_bridge::frb(mirror(MetadataType))]
pub enum _MetadataType {
    File,
    Directory,
    Network,
    Virtual,
}

/// FRB-friendly mirror of the SDK's recursive `Metadata<()>` tree.
///
/// `Arc<Mutex<>>` sub-metadatas are flattened into a plain recursive `Vec`,
/// and the `PhantomData` marker is dropped, so codegen produces a clean Dart
/// class.
#[derive(Debug, Clone)]
pub struct MetadataNode {
    pub lid: u64,
    pub rid: u64,
    pub file_size: u64,
    pub file_cnt: u64,
    pub name: String,
    pub alias_name: Vec<String>,
    pub origin_name: String,
    pub description: String,
    pub flags: u32,
    pub metadata_type: MetadataType,
    pub origin: String,
    pub data_file_map_id: Option<u64>,
    pub cover_file_map_id: Option<u64>,
    pub sub_metadatas: Vec<MetadataNode>,
    pub url: String,
    pub checksum: String,
    pub extend: HashMap<String, String>,
}

impl From<Metadata<()>> for MetadataNode {
    fn from(meta: Metadata<()>) -> Self {
        Self {
            lid: meta.lid,
            rid: meta.rid,
            file_size: meta.file_size,
            file_cnt: meta.file_cnt,
            name: meta.name,
            alias_name: meta.alias_name,
            origin_name: meta.origin_name,
            description: meta.description,
            flags: meta.flags,
            metadata_type: meta.metadata_type,
            origin: meta.origin,
            data_file_map_id: meta.data_file_map_id,
            cover_file_map_id: meta.cover_file_map_id,
            sub_metadatas: meta
                .sub_metadatas
                .into_iter()
                .map(|arc| {
                    let inner = arc.lock().unwrap_or_else(|e| e.into_inner()).clone();
                    MetadataNode::from(inner)
                })
                .collect(),
            url: meta.url,
            checksum: meta.checksum.iter().map(|b| format!("{:02x}", b)).collect(),
            extend: meta.extend,
        }
    }
}

// ---------------------------------------------------------------------------
// Flutter Rust Bridge stubs (sync helpers)
// ---------------------------------------------------------------------------

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

// ---------------------------------------------------------------------------
// CosmoxSdk — FRB generates a Dart class with static methods.
// ---------------------------------------------------------------------------

#[flutter_rust_bridge::frb(opaque)]
pub struct CosmoxSdk {
    api: HttpApi,
}

#[allow(non_snake_case)]
impl CosmoxSdk {
    /// New the cosmox sdk client (sync — no network call).
    #[flutter_rust_bridge::frb(sync)]
    pub fn new(hostname: String, port: u16) -> Self {
        let hostname: &'static str = Box::leak(hostname.into_boxed_str());
        let api = create_client::<HttpApi>(hostname, port);
        Self { api }
    }

    // -----------------------------------------------------------------------
    // Auth
    // -----------------------------------------------------------------------

    pub async fn login(
        &mut self,
        username: String,
        password: String,
    ) -> Result<Option<String>, SdkError> {
        self.api
            .login(UserLogin {
                ident: UserLoginIdent::Username(username),
                password,
            })
            .await?;
        Ok(self.api.get_token())
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn getToken(&self) -> Option<String> {
        self.api.get_token()
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn setToken(&mut self, token: String) -> Result<(), SdkError> {
        self.api.set_token(token);
        Ok(())
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn logout(&mut self) {
        self.api.logout();
    }

    // -----------------------------------------------------------------------
    // System
    // -----------------------------------------------------------------------

    pub async fn systemInfo(&self) -> Result<SystemInfo, SdkError> {
        self.api.system_info().await
    }

    pub async fn systemAbout(&self) -> Result<String, SdkError> {
        self.api.system_about().await
    }

    pub async fn systemLog(&self) -> Result<String, SdkError> {
        self.api.system_log().await
    }

    pub async fn systemRestart(&self) -> Result<(), SdkError> {
        self.api.system_restart().await
    }

    pub async fn systemShutdown(&self) -> Result<(), SdkError> {
        self.api.system_shutdown().await
    }

    // -----------------------------------------------------------------------
    // User
    // -----------------------------------------------------------------------

    pub async fn userSelf(&self) -> Result<User, SdkError> {
        self.api.user_get(0).await
    }

    pub async fn userGet(&self, uid: u64) -> Result<User, SdkError> {
        self.api.user_get(uid).await
    }

    pub async fn userQuery(&self) -> Result<Vec<User>, SdkError> {
        self.api
            .user_query(UserQueryRequest {
                status: None,
                role: None,
                search: None,
                sort: None,
                page: None,
                page_size: 40,
            })
            .await
    }

    pub async fn userRegister(
        &self,
        username: String,
        password: String,
        confirmPassword: String,
    ) -> Result<UserResp, SdkError> {
        self.api
            .user_register(cosmox_sdk::types::UserSignUp {
                username,
                password,
                confirm_password: confirmPassword,
                nickname: None,
                email: None,
            })
            .await
    }

    pub async fn userQueryDevices(
        &self,
        uid: Option<u64>,
        sort: Option<String>,
        page: Option<u64>,
        pageSize: u64,
    ) -> Result<Vec<DeviceSession>, SdkError> {
        self.api
            .user_query_devices(DeviceQueryRequest {
                uid,
                sort,
                page,
                page_size: pageSize,
            })
            .await
    }

    pub async fn logoutDevice(&self, did: u64) -> Result<(), SdkError> {
        self.api.logout_device(did).await
    }

    pub async fn logoutUser(&self, uid: u64) -> Result<(), SdkError> {
        self.api.logout_user(uid).await
    }

    pub async fn userRegisterWithProfile(
        &self,
        username: String,
        password: String,
        confirmPassword: String,
        nickname: Option<String>,
        email: Option<String>,
    ) -> Result<UserResp, SdkError> {
        self.api
            .user_register(cosmox_sdk::types::UserSignUp {
                username,
                password,
                confirm_password: confirmPassword,
                nickname,
                email,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Library
    // -----------------------------------------------------------------------

    pub async fn libraryQuery(&self) -> Result<Vec<Library>, SdkError> {
        self.api
            .library_query(LibraryQueryRequest {
                sort: None,
                page: None,
                page_size: 40,
            })
            .await
    }

    pub async fn libraryGet(&self, lid: u64) -> Result<Library, SdkError> {
        self.api.library_get(lid).await
    }

    pub async fn libraryTypes(&self) -> Result<Vec<LibraryType>, SdkError> {
        self.api.library_type_all().await
    }

    pub async fn libraryAdd(
        &self,
        name: String,
        description: Option<String>,
        typeId: u64,
        tags: Vec<u64>,
        libraryPaths: Vec<String>,
    ) -> Result<(Library, Vec<LibrariesRelatedTags>, Vec<LibraryPath>), SdkError> {
        self.api
            .library_add(cosmox_sdk::types::LibraryAdd {
                name,
                description,
                r#type: typeId,
                tags,
                library_paths: libraryPaths,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Resource
    // -----------------------------------------------------------------------

    pub async fn resourceGet(&self, rid: u64) -> Result<Resource, SdkError> {
        self.api.resource_get(rid).await
    }

    pub async fn resourceQuery(&self, lid: u64) -> Result<Vec<Resource>, SdkError> {
        self.api
            .resource_query(ResourceQueryRequest {
                sort: None,
                page: None,
                page_size: 40,
                lid,
                level: None,
                max_level: None,
                min_level: None,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Tag
    // -----------------------------------------------------------------------

    pub async fn tagQuery(&self) -> Result<Vec<Tag>, SdkError> {
        self.api
            .tag_query(TagQueryRequest {
                tid: None,
                sort: None,
                page: None,
                page_size: 40,
            })
            .await
    }

    pub async fn tagCatalog(&self) -> Result<Vec<TagCatalogEntry>, SdkError> {
        self.api.tag_catalog().await
    }

    pub async fn tagGroupQuery(&self) -> Result<Vec<TagGroup>, SdkError> {
        self.api
            .tag_group_query(cosmox_sdk::types::TagGroupQueryRequest {
                tgid: None,
                sort: None,
                page: None,
                page_size: 40,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Scanner
    // -----------------------------------------------------------------------

    pub async fn scannerScan(&self, lid: u64) -> Result<String, SdkError> {
        self.api.scanner_scan(lid).await
    }

    pub async fn scannerScanAll(&self) -> Result<String, SdkError> {
        self.api.scanner_scan_all().await
    }

    pub async fn scannerInfo(&self) -> Result<ScannerInfo, SdkError> {
        self.api.scanner_info().await
    }

    pub async fn scannerStatus(&self) -> Result<ScannerStatus, SdkError> {
        self.api.scanner_get_status().await
    }

    // -----------------------------------------------------------------------
    // Initialize (first-boot setup)
    // -----------------------------------------------------------------------

    pub async fn initialize(
        &self,
        adminPassword: String,
        confirmPassword: String,
    ) -> Result<InitStatus, SdkError> {
        self.api
            .initialize(cosmox_sdk::types::InitializeConfig {
                admin_password: adminPassword,
                admin_confirm_password: confirmPassword,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // System (cont.)
    // -----------------------------------------------------------------------

    pub async fn systemDeleteAll(&self) -> Result<(), SdkError> {
        self.api.system_delete_all().await
    }

    // -----------------------------------------------------------------------
    // User (cont.)
    // -----------------------------------------------------------------------

    pub async fn userDelete(&self, uid: u64) -> Result<(), SdkError> {
        self.api.user_delete(uid).await
    }

    pub async fn userRoleAdd(&self, uid: u64, rid: u64) -> Result<(), SdkError> {
        self.api
            .user_role_add(cosmox_sdk::types::UserRoleAddRequest { uid, rid })
            .await
    }

    pub async fn userUploadAvatar(
        &self,
        uid: u64,
        data: Vec<u8>,
    ) -> Result<PushResponse, SdkError> {
        self.api.user_upload_avatar(uid, data).await
    }

    // -----------------------------------------------------------------------
    // Library (cont.)
    // -----------------------------------------------------------------------

    pub async fn libraryModify(
        &self,
        lid: u64,
        name: Option<String>,
        description: Option<String>,
    ) -> Result<(), SdkError> {
        self.api
            .library_modify(lid, cosmox_sdk::types::LibraryModify { name, description })
            .await
    }

    pub async fn libraryDelete(&self, lid: u64) -> Result<(), SdkError> {
        self.api
            .library_delete(cosmox_sdk::types::LibraryDeleteRequest { lid })
            .await
    }

    // -----------------------------------------------------------------------
    // Resource (cont.)
    // -----------------------------------------------------------------------

    pub async fn resourceAdd(
        &self,
        name: String,
        lid: u64,
        description: Option<String>,
        level: u64,
    ) -> Result<String, SdkError> {
        self.api
            .resource_add(cosmox_sdk::types::ResourceAddRequest {
                name,
                lid,
                description,
                level,
            })
            .await
            .map(|v| v.to_string())
    }

    pub async fn resourceDelete(&self, rid: u64) -> Result<(), SdkError> {
        self.api.resource_delete(rid).await
    }

    pub async fn resourceAddTag(&self, rid: u64, tagIds: Vec<u64>) -> Result<String, SdkError> {
        self.api
            .resource_add_tag(rid, tagIds)
            .await
            .map(|v| v.to_string())
    }

    pub async fn resourceGetMetadata(&self, rid: u64) -> Result<String, SdkError> {
        self.api
            .resource_get_metadata(rid)
            .await
            .map(|v| v.to_string())
    }

    // -----------------------------------------------------------------------
    // Tag (cont.)
    // -----------------------------------------------------------------------

    pub async fn tagGet(&self, tid: u64) -> Result<Tag, SdkError> {
        self.api.tag_get(tid).await
    }

    pub async fn tagAdd(&self, label: String, tgid: u64) -> Result<u64, SdkError> {
        self.api
            .tag_add(cosmox_sdk::types::TagAddRequest { label, tgid })
            .await
    }

    // -----------------------------------------------------------------------
    // Tag Group (cont.)
    // -----------------------------------------------------------------------

    pub async fn tagGroupGet(&self, tgid: u64) -> Result<TagGroup, SdkError> {
        self.api.tag_group_get(tgid).await
    }

    pub async fn tagGroupAdd(&self, label: String) -> Result<u64, SdkError> {
        self.api
            .tag_group_add(cosmox_sdk::types::TagGroupAddRequest { label })
            .await
    }

    pub async fn tagGroupDelete(&self, tgid: u64) -> Result<(), SdkError> {
        self.api
            .tag_group_delete(cosmox_sdk::types::TagGroupDeleteRequest { tgid })
            .await
    }

    // -----------------------------------------------------------------------
    // Path
    // -----------------------------------------------------------------------

    pub async fn pathSubPath(&self, path: String, showHide: bool) -> Result<Vec<String>, SdkError> {
        self.api.path_sub_path(path, showHide).await
    }

    // -----------------------------------------------------------------------
    // Metadata
    // -----------------------------------------------------------------------

    pub async fn metadataQuery(
        &self,
        rootNode: Option<u64>,
        depth: u64,
    ) -> Result<MetadataNode, SdkError> {
        let key = rootNode
            .map(cosmox_sdk::types::MetadataQueryKey::Id)
            .unwrap_or(cosmox_sdk::types::MetadataQueryKey::Root);
        self.api
            .metadata_query::<()>(key, depth as usize)
            .await
            .map(MetadataNode::from)
    }

    pub async fn metadataGet(&self, mid: u64) -> Result<MetadataNode, SdkError> {
        self.api
            .metadata_get::<()>(mid)
            .await
            .map(MetadataNode::from)
    }

    // -----------------------------------------------------------------------
    // Search
    // -----------------------------------------------------------------------

    pub async fn search(&self, request: SearchRequest) -> Result<String, SdkError> {
        self.api.search(request).await.map(|v| v.to_string())
    }

    // -----------------------------------------------------------------------
    // File
    // -----------------------------------------------------------------------

    pub async fn itemPush(&self, data: Vec<u8>) -> Result<PushResponse, SdkError> {
        self.api.item_push(data).await
    }

    pub async fn itemPull(&self, id: u64) -> Result<String, SdkError> {
        let base_url = self.api.base_url.as_str();
        Ok(format!("{base_url}/item/{id}/pull"))
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn staticItem(&self, path: String) -> Result<String, SdkError> {
        let base_url = self.api.base_url.trim_end_matches("/api");
        Ok(format!("{base_url}/{path}"))
    }

    // -----------------------------------------------------------------------
    // Plugin
    // -----------------------------------------------------------------------

    pub async fn pluginInfo(&self) -> Result<String, SdkError> {
        self.api.plugin_info().await
    }

    pub async fn pluginQuery(
        &self,
        name: Option<String>,
        status: Option<String>,
        pluginType: Option<String>,
    ) -> Result<Vec<PluginQueryItem>, SdkError> {
        self.api
            .plugin_query(cosmox_sdk::types::PluginQueryRequest {
                name,
                status,
                plugin_type: pluginType,
                sort: None,
                page: None,
                page_size: 40,
            })
            .await
    }

    pub async fn pluginInstall(&self, url: Option<String>) -> Result<String, SdkError> {
        self.api
            .plugin_install(cosmox_sdk::types::InstallPlugin::Url(
                Url::parse(&url.ok_or(SdkError::Internal("Expect a url".to_string()))?)
                    .map_err(|err| SdkError::Internal(err.to_string()))?,
            ))
            .await
    }

    pub async fn pluginUninstall(&self, name: String) -> Result<(), SdkError> {
        self.api.plugin_uninstall(name).await
    }

    pub async fn pluginEnable(&self, name: String) -> Result<(), SdkError> {
        self.api.plugin_enable(name).await
    }

    pub async fn pluginDisable(&self, name: String) -> Result<(), SdkError> {
        self.api.plugin_disable(name).await
    }

    // -----------------------------------------------------------------------
    // ACL
    // -----------------------------------------------------------------------

    pub async fn aclQueryRole(&self) -> Result<Vec<Role>, SdkError> {
        self.api.acl_query_role().await
    }

    pub async fn aclQueryPermission(&self) -> Result<Vec<Permission>, SdkError> {
        self.api.acl_query_permission().await
    }

    pub async fn aclAddRole(
        &self,
        name: String,
        description: Option<String>,
    ) -> Result<(), SdkError> {
        self.api
            .acl_add_role(cosmox_sdk::types::RoleAddRequest { name, description })
            .await
    }

    pub async fn aclDeleteRole(&self, rid: u64) -> Result<(), SdkError> {
        self.api.acl_delete_role(rid).await
    }

    pub async fn aclAddPermission(
        &self,
        name: String,
        description: Option<String>,
    ) -> Result<(), SdkError> {
        self.api
            .acl_add_permission(cosmox_sdk::types::PermissionAddRequest { name, description })
            .await
    }

    pub async fn aclDeletePermission(&self, pid: u64) -> Result<(), SdkError> {
        self.api.acl_delete_permission(pid).await
    }

    pub async fn aclAddPermissionForRole(&self, rid: u64, pid: u64) -> Result<(), SdkError> {
        self.api
            .acl_add_permission_for_role(cosmox_sdk::types::RoleLinkPermissionAddRequest {
                rid,
                pid,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Scanner (cont.)
    // -----------------------------------------------------------------------

    pub async fn scannerAddTask(
        &self,
        lid: Option<u64>,
        fullScan: Option<bool>,
    ) -> Result<(), SdkError> {
        self.api
            .scanner_add_task(cosmox_sdk::types::ScannerTaskAddRequest {
                lid,
                full_scan: fullScan,
            })
            .await
    }

    // -----------------------------------------------------------------------
    // Docs
    // -----------------------------------------------------------------------

    pub async fn openapi(&self) -> Result<String, SdkError> {
        self.api.openapi().await
    }

    pub async fn docs(&self) -> Result<String, SdkError> {
        self.api.docs().await
    }
}
