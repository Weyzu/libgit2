module git2.cred_helpers;

import git2.transport;

extern (C):

struct git_cred_userpass_payload {
	char *username;
	char *password;
}

int git_cred_userpass(
		git_cred **cred,
		const(char)* url,
		const(char)* user_from_url,
		uint allowed_types,
		void *payload);
