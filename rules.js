{
	"rules": {

		"users": {
			"$user_id": { 
				".write": "user_id === auth.uid",
				".validate": "newData.hasChildren(['username'])",
				"username": { ".validate": "newData.isString() && newData.val().length > 0" },
				"first_name": { ".validate": "newData.isString()" },
				"last_name": { ".validate": "newData.isString()" },
				"email": { ".validate": "newData.isString()" },
				"friends": {
					"$friend_id": { ".validate": "root.child('users/'+$user_id).exists()" }
				}
			}
		},

		"chats": {
			"$chat_id": {
				".read": "root.child('members/'+$chat_id+'/'+auth.uid).exists()"
				".write": "root.child('members/'+$chat_id+'/'+auth.uid).exists()",
				".validate": "newData.isString() && newData.hasChildren(['group', 'lastMessage', 'timestamp'])",
				"group": { ".validate": "newData.isBoolean()"	},
				"lastMessage": { ".validate": "newData.isString() && newData.val().length > 0" },
				"timestamp": { ".validate": "newData.val() <= now "},
				"$other": { ".validate": false }
			}
		},

		"members": {
			"$chat_id": {
				".write": "root.child('members/'+$chat_id+'/'+auth.uid).exists()",
				".validate": "newData.isString() && root.child('chats/'+$chat_id).exists()",
				"$user_id": {	".validate": "root.child('users/'+$user_id).exists()"	}
			}
		},

		"messages": {
			"$chat_id": {
				".read": "root.child('members/'+$chat_id+'/'+auth.uid).exists()",
				".validate": "root.child('chats/'+$chat_id).exists()",
				"$message_id": {
					".write": "root.child('members/'+$chat_id+'/'+auth.uid).exists()",
					"message": { ".validate": "newData.isString && newData.val().length > 0" },
					"author": { ".validate": "newData.isString && root.child('users/'+newData).exists()" },
					"timestamp": { ".validate": "newData.val() <= now "}
				}
			}
		}
	}
}