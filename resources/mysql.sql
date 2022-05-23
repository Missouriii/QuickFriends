-- #!mysql
-- #{ quickfriends
-- # { init
CREATE TABLE IF NOT EXISTS quickfriends_player_data (
    uuid CHAR(36) PRIMARY KEY,
    username CHAR(100) NOT NULL,
    last_os CHAR(20) NOT NULL,
    last_join_time TIMESTAMP NOT NULL,
    prefers_text BOOLEAN NOT NULL CHECK (prefers_text IN (0, 1)),
    os_visibility INT NOT NULL,
    mute_friend_requests BOOLEAN NOT NULL CHECK (mute_friend_requests IN (0, 1))
);
-- #&
CREATE TABLE IF NOT EXISTS quickfriends_player_friends (
    requester CHAR(36) NOT NULL,
    accepter CHAR(36) NOT NULL,
    creation_time TIMESTAMP NOT NULL,

    PRIMARY KEY(requester, accepter),

    FOREIGN KEY (requester)
        REFERENCES quickfriends_player_data(uuid)
        ON DELETE CASCADE,
    FOREIGN KEY (accepter)
        REFERENCES quickfriends_player_data(uuid)
        ON DELETE CASCADE
)
-- #&
CREATE TABLE IF NOT EXISTS quickfriends_player_blocked (
    player CHAR(36) NOT NULL,
    blocked CHAR(36) NOT NULL,
    creation_time TIMESTAMP NOT NULL,

    PRIMARY KEY(player, blocked),

    FOREIGN KEY (player)
        REFERENCES quickfriends_player_data(uuid)
        ON DELETE CASCADE,
    FOREIGN KEY (blocked)
        REFERENCES quickfriends_player_data(uuid)
        ON DELETE CASCADE
)
-- # }
-- # { get_player_data
-- #     :uuid string
SELECT * FROM quickfriends_player_data
WHERE uuid=:uuid;
-- # }
-- # { touch_player_data
-- #     :uuid string
-- #     :username string
-- #     :last_os string
-- #     :last_join_time int
-- #     :default_prefers_text int
-- #     :default_os_visibility int
-- #     :default_mute_friend_requests int
INSERT INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :uuid, :username, :last_os, FROM_UNIXTIME(:last_join_time),
  :default_prefers_text, :default_os_visibility, :default_mute_friend_requests
) ON DUPLICATE KEY UPDATE username=:username, last_os=:last_os, last_join_time=FROM_UNIXTIME(:last_join_time);
-- # }
-- # { update_player_data
-- #     :uuid string
-- #     :username string
-- #     :last_os string
-- #     :last_join_time int
-- #     :prefers_text int
-- #     :os_visibility int
-- #     :mute_friend_requests int
REPLACE INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :uuid, :username, :last_os, FROM_UNIXTIME(:last_join_time),
  :prefers_text, :os_visibility, :mute_friend_requests
);
-- # }
-- # { add_friend
-- #     :requester_uuid string
-- #     :requester_username string
-- #     :requester_last_os string
-- #     :requester_last_join_time int
-- #     :accepter_uuid string
-- #     :accepter_username string
-- #     :accepter_last_os string
-- #     :accepter_last_join_time int
-- #     :default_prefers_text int
-- #     :default_os_visibility int
-- #     :default_mute_friend_requests int
-- #     :creation_time int
INSERT INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :requester_uuid, :requester_username, :requester_last_os, FROM_UNIXTIME(:requester_last_join_time),
  :default_prefers_text, :default_os_visibility, :default_mute_friend_requests
) ON DUPLICATE KEY UPDATE username=:requester_username, last_os=:requester_last_os, last_join_time=FROM_UNIXTIME(:requester_last_join_time);
-- #&
INSERT INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :accepter_uuid, :accepter_username, :accepter_last_os, FROM_UNIXTIME(:accepter_last_join_time),
  :default_prefers_text, :default_os_visibility, :default_mute_friend_requests
) ON DUPLICATE KEY UPDATE username=:accepter_username, last_os=:accepter_last_os, last_join_time=FROM_UNIXTIME(:accepter_last_join_time);
-- #&
REPLACE INTO quickfriends_player_friends
(requester, accepter, creation_time)
VALUES (:requester_uuid, :accepter_uuid, FROM_UNIXTIME(:creation_time));
-- # }
-- # { remove_friend
-- #     :uuids list:string
DELETE FROM quickfriends_player_friends
WHERE requester IN :uuids AND accepter IN :uuids;
-- # }
-- # { list_friends
-- #     :uuid string
SELECT * FROM quickfriends_player_friends
WHERE requester=:uuid OR accepter=:uuid;
-- # }
-- # { block_player
-- #     :player_uuid string
-- #     :player_username string
-- #     :player_last_os string
-- #     :player_last_join_time int
-- #     :blocked_uuid string
-- #     :blocked_username string
-- #     :blocked_last_os string
-- #     :blocked_last_join_time int
-- #     :default_prefers_text int
-- #     :default_os_visibility int
-- #     :default_mute_friend_requests int
-- #     :creation_time int
INSERT INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :player_uuid, :player_username, :player_last_os, FROM_UNIXTIME(:player_last_join_time),
  :default_prefers_text, :default_os_visibility, :default_mute_friend_requests
) ON DUPLICATE KEY UPDATE username=:player_username, last_os=:player_last_os, last_join_time=FROM_UNIXTIME(:player_last_join_time);
-- #&
INSERT INTO quickfriends_player_data (
  uuid, username, last_os, last_join_time,
  prefers_text, os_visibility, mute_friend_requests
) VALUES (
  :blocked_uuid, :blocked_username, :blocked_last_os, FROM_UNIXTIME(:blocked_last_join_time),
  :default_prefers_text, :default_os_visibility, :default_mute_friend_requests
) ON DUPLICATE KEY UPDATE username=:blocked_username, last_os=:blocked_last_os, last_join_time=FROM_UNIXTIME(:blocked_last_join_time);
-- #&
REPLACE INTO quickfriends_player_blocked
(player, blocked, creation_time) VALUES
(:player_uuid, :blocked_uuid, FROM_UNIXTIME(:creation_time));
-- # }
-- # { unblock_player
-- #     :player string
-- #     :blocked string
DELETE FROM quickfriends_player_blocked
WHERE player=:player AND blocked=:blocked;
-- # }
-- # { list_blocked
-- #     :uuid string
SELECT * FROM quickfriends_player_blocked
WHERE player=:uuid;
-- # }
-- # { list_blocked_by
-- #     :uuid string
SELECT * FROM quickfriends_player_blocked
WHERE blocked=:uuid;
-- # }
-- #}
