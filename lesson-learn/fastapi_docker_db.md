# FastAPI + Docker + Postgres 小抄

- 專案有 `dockerfile` 與 `docker-compose.yml`，compose 會啟兩個服務：`postgres` (Port 5432) 與 `backend` (FastAPI + Uvicorn，映射到主機 3000)。在裝好 Docker 的環境執行 `docker compose up --build` 就能啟動整套 API 與 DB。
- `.env` 同時供 Postgres 與 FastAPI 使用，`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` 會建立資料庫與帳號，而 `DATABASE_URL` 讓 FastAPI ORM 連線；改變任一項都要同步更新兩邊。
- `db/init.sql` 在資料 volume 第一次建立時執行：啟用 `uuid-ossp`、建立 `users` 表（UUID 主鍵、email 唯一、bcrypt 雜湊密碼）並種下 admin 帳號。`VALUES` 需要補逗號 (`'admin user', 'admin@mail.com', ...`) 才不會初始化失敗。
- `docker-entrypoint-initdb.d` 的 SQL 只會跑一次；若修改 schema 後要重建 dev DB，必須 `docker compose down -v`（會刪資料）或導入 Alembic 這類 migration 工具。
- 一個應用通常只需一個 database、裡面放多張表並用外鍵關聯；要新增表可以在原 `init.sql` 追加 `CREATE TABLE`，也可以拆成多個 `.sql` 檔，將整個 `db/` 掛到 `/docker-entrypoint-initdb.d/`，Postgres 會依檔名順序執行。
- 若要多個 database：可以在同一 Postgres 內 `CREATE DATABASE other_db` 並寫對應 SQL 或直接建立第二個 `postgres` 容器，各自連不同 DB；無論哪種，FastAPI 的 `DATABASE_URL` 都要指向正確的 DB。
- PostgreSQL schema 是 DB 內的命名空間，例如 `cms.articles`。用 schema 分類時，ORM 模型與 SQL 查詢要記得指定 schema，否則會找不到表。
- 常見陷阱：SQL 語法錯誤（逗號/分號）；忘了雜湊密碼；調整環境變數後未同步應用；不備份就 `docker compose down -v`；以為新增 SQL 檔會自動套用到既有資料庫。

- `.env` 含密碼/連線字串，不應放進 Git；提供一份 `/.env.example` 列出需要的鍵讓其他人複製填寫，開發者在本機依照模板建立自己的 `.env`。
- 同一專案可能有 `.env.dev`, `.env.prod` 等檔案：Compose 預設只讀同層 `.env`，可在啟動前把目標檔案複製成 `.env`，或利用 `docker compose --env-file .env.prod up` / `ENV_FILE=.env.dev docker compose up`（配合 `env_file: - ${ENV_FILE:-.env.dev}`）來切換；FastAPI 也要讀同一份檔案才不會出現設定不一致。
