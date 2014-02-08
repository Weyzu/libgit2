module git2.transport;

import git2.indexer;
import git2.net;
import git2.util;
import git2.types;

extern (C):

version (GIT_SSH)
{
    static assert(0, "dlibgit does not support SSH yet.");
    // import ssh2;
}

enum git_credtype_t {
	GIT_CREDTYPE_USERPASS_PLAINTEXT = 1,
	GIT_CREDTYPE_SSH_KEYFILE_PASSPHRASE = 2,
	GIT_CREDTYPE_SSH_PUBLICKEY = 3,
}
mixin _ExportEnumMembers!git_credtype_t;

struct git_cred {
	git_credtype_t credtype;
	void function(git_cred *cred) free;
};

struct git_cred_userpass_plaintext {
	git_cred parent;
	char *username;
	char *password;
};

version (GIT_SSH)
{
    static assert(0, "dlibgit does not support SSH yet.");
    // typedef LIBSSH2_USERAUTH_PUBLICKEY_SIGN_FUNC((*git_cred_sign_callback));

    struct git_cred_ssh_keyfile_passphrase {
        git_cred parent;
        char *publickey;
        char *privatekey;
        char *passphrase;
    };

    struct git_cred_ssh_publickey {
        git_cred parent;
        char *publickey;
        size_t publickey_len;
        void *sign_callback;
        void *sign_data;
    };
}

int git_cred_userpass_plaintext_new(
	git_cred **out_,
	const(char)* username,
	const(char)* password);

version (GIT_SSH)
{
    static assert(0, "dlibgit does not support SSH yet.");
    // typedef LIBSSH2_USERAUTH_PUBLICKEY_SIGN_FUNC((*git_cred_sign_callback));

	int git_cred_ssh_keyfile_passphrase_new(
		git_cred **out_,
		const(char)* publickey,
		const(char)* privatekey,
		const(char)* passphrase);

    int git_cred_ssh_publickey_new(
        git_cred **out_,
        const(char)* publickey,
        size_t publickey_len,
        git_cred_sign_callback,
        void *sign_data);
}

alias git_cred_acquire_cb = int function(
	git_cred **cred,
	const(char)* url,
	const(char)* username_from_url,
	uint allowed_types,
	void *payload);

enum git_transport_flags_t {
	GIT_TRANSPORTFLAGS_NONE = 0,
	GIT_TRANSPORTFLAGS_NO_CHECK_CERT = 1
}
mixin _ExportEnumMembers!git_transport_flags_t;

alias git_transport_message_cb = void function(const(char)* str, int len, void *data);

struct git_transport
{
	uint version_ = GIT_TRANSPORT_VERSION;

	int function(git_transport *transport,
		git_transport_message_cb progress_cb,
		git_transport_message_cb error_cb,
		void *payload) set_callbacks;
	int function(git_transport *transport,
		const(char)* url,
		git_cred_acquire_cb cred_acquire_cb,
		void *cred_acquire_payload,
		int direction,
		int flags) connect;
	int function(git_transport *transport,
		git_headlist_cb list_cb,
		void *payload) ls;
	int function(git_transport *transport, git_push *push) push;
	int function(git_transport *transport,
		git_repository *repo,
		const(git_remote_head**) refs_,
		size_t count) negotiate_fetch;
	int function(git_transport *transport,
		git_repository *repo,
		git_transfer_progress *stats,
		git_transfer_progress_callback progress_cb,
		void *progress_payload) download_pack;
	int function(git_transport *transport) is_connected;
	int function(git_transport *transport, int *flags) read_flags;
	void function(git_transport *transport) cancel;
	int function(git_transport *transport) close;
	void function(git_transport *transport) free;
}

enum GIT_TRANSPORT_VERSION = 1;
enum git_transport GIT_TRANSPORT_INIT = { GIT_TRANSPORT_VERSION };

int git_transport_new(git_transport **out_, git_remote *owner, const(char)* url);

alias git_transport_cb = int function(git_transport **out_, git_remote *owner, void *param);

int git_transport_dummy(
	git_transport **out_,
	git_remote *owner,
	/* NULL */ void *payload);
int git_transport_local(
	git_transport **out_,
	git_remote *owner,
	/* NULL */ void *payload);
int git_transport_smart(
	git_transport **out_,
	git_remote *owner,
	/* (git_smart_subtransport_definition *) */ void *payload);
enum git_smart_service_t {
	GIT_SERVICE_UPLOADPACK_LS = 1,
	GIT_SERVICE_UPLOADPACK = 2,
	GIT_SERVICE_RECEIVEPACK_LS = 3,
	GIT_SERVICE_RECEIVEPACK = 4,
}
mixin _ExportEnumMembers!git_smart_service_t;

struct git_smart_subtransport_stream {
	git_smart_subtransport *subtransport;

	int function(
			git_smart_subtransport_stream *stream,
			char *buffer,
			size_t buf_size,
			size_t *bytes_read) read;
	int function(
			git_smart_subtransport_stream *stream,
			const(char)* buffer,
			size_t len) write;
	void function(
			git_smart_subtransport_stream *stream) free;
}

struct git_smart_subtransport {
	int function(
			git_smart_subtransport_stream **out_,
			git_smart_subtransport *transport,
			const(char)* url,
			git_smart_service_t action) action;
	int function(git_smart_subtransport *transport) close;
	void function(git_smart_subtransport *transport) free;
}

alias git_smart_subtransport_cb = int function(
	git_smart_subtransport **out_,
	git_transport* owner);

struct git_smart_subtransport_definition {
	git_smart_subtransport_cb callback;
	uint rpc;
}

int git_smart_subtransport_http(
	git_smart_subtransport **out_,
	git_transport* owner);
int git_smart_subtransport_git(
	git_smart_subtransport **out_,
	git_transport* owner);
int git_smart_subtransport_ssh(
	git_smart_subtransport **out_,
	git_transport* owner);
