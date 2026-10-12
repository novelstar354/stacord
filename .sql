--id 一覧

SELECT
    id AS "内部ユーザーID",
    user_id AS "ログインID",
    display_name AS "表示名",
    created_at AS "登録日時",
    CASE
        WHEN is_banned THEN 'BAN中'
        ELSE '有効'
    END AS "アカウント状態",
    ban_reason AS "BAN理由",
    banned_at AS "BAN日時",
    banned_by AS "BAN実行者"
FROM public.stacord_accounts
ORDER BY is_banned DESC, created_at ASC;

SELECT
    id AS "内部ユーザーID",
    user_id AS "ログインID",
    display_name AS "表示名",
    created_at AS "登録日時",
    CASE
        WHEN is_banned THEN 'BAN中'
        ELSE '有効'
    END AS "アカウント状態",
    ban_reason AS "BAN理由",
    banned_at AS "BAN日時",
    banned_by AS "BAN実行者"
FROM public.stacord_accounts
ORDER BY is_banned DESC, created_at ASC;

--ban

UPDATE public.stacord_accounts
SET
    is_banned = true,
    banned_at = now(),
    ban_reason = '利用規約違反',
    banned_by = '管理者'
WHERE lower(user_id) = lower('test')
RETURNING user_id, display_name, is_banned, ban_reason, banned_at;

--ban解除

UPDATE public.stacord_accounts
SET
    is_banned = false,
    banned_at = NULL,
    ban_reason = NULL,
    banned_by = NULL
WHERE lower(user_id) = lower('test')
RETURNING user_id, display_name, is_banned;


-- msg一覧

SELECT
    c.id AS "チャットID",
    CASE
        WHEN c.type = 'group' THEN
            COALESCE(c.name, 'グループチャット')
        ELSE
            COALESCE(
                (
                    SELECT string_agg(
                        a.display_name,
                        '、' ORDER BY a.display_name
                    )
                    FROM public.stacord_conversation_members m
                    JOIN public.stacord_accounts a
                        ON a.id = m.user_id
                    WHERE m.conversation_id = c.id
                ),
                '参加者なし'
            )
    END AS "チャット名・表示名",
    (
        SELECT string_agg(
            a.display_name,
            '、' ORDER BY a.display_name
        )
        FROM public.stacord_conversation_members m
        JOIN public.stacord_accounts a
            ON a.id = m.user_id
        WHERE m.conversation_id = c.id
    ) AS "参加者一覧",
    (
        SELECT msg.body
        FROM public.stacord_messages msg
        WHERE msg.conversation_id = c.id
        ORDER BY msg.created_at DESC, msg.id DESC
        LIMIT 1
    ) AS "最新メッセージ",
    (
        SELECT msg.created_at
        FROM public.stacord_messages msg
        WHERE msg.conversation_id = c.id
        ORDER BY msg.created_at DESC, msg.id DESC
        LIMIT 1
    ) AS "最終メッセージ日時",
    c.created_at AS "作成日時"
FROM public.stacord_conversations c
ORDER BY c.created_at DESC;
