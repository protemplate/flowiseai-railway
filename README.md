## 📝 Notes
Use the flowise-railway template (https://railway.app/template/pn4G8S) if you don't need pre-configured persisted volume, postgis and private networking on Railway.

# Deploy Flowise with Railway (Shared PostGIS Instance)

## ✨ Features
- Pre-configured persisted volume.
- Most of the Flowise configs are pre-configured.
- Uses shared Postgres/PostGIS instance (perfect for n8n + Flowise setup).
- Automatic database initialization on first deployment.
- The communication from Flowise to database is accomplished through the railway internal private network, reducing unnecessary egress fees.

## ✅ Prerequisite
- Postgres or PostGIS is already deployed to an environment on Railway (e.g., shared with n8n)
- Flowise and Postgres have to be deployed to the same environment in order to leverage the benefits of private networking on Railway.
- The PostGIS instance should have the main database (e.g., `railway`) already created
- The `flowise` database will be automatically created on first deployment

----

## 💁‍♂️ Usage

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/A7Dwg9?referralCode=OYCuBb)

### 🚀 Quick start

1. Click Deploy Now

2. Change to your preferred repository name

3. Click Configure and click Save Config for both services.

4. Click Deploy.

5. Let Railway deploy all the services for you.

6. Once the process is successful, you will be able to view a deployed URL.


### 💡 Integration with existing n8n + PostGIS setup

If you already have n8n running with PostGIS on Railway, you can add Flowise to share the same database instance:

1. Deploy this Flowise template to the **same Railway environment** as your PostGIS database

2. Configure the following environment variables in Railway:

- `DATABASE_HOST`: Use `${{RAILWAY_PRIVATE_DOMAIN}}` from your PostGIS service
- `DATABASE_NAME`: `flowise` (will be created automatically)
- `DATABASE_USER`: `${{POSTGRES_USER}}` (from your PostGIS service)
- `DATABASE_PASSWORD`: `${{POSTGRES_PASSWORD}}` (from your PostGIS service)
- `DATABASE_PORT`: `5432`
- `DATABASE_TYPE`: `postgres`
- `DATABASE_SSL`: `true`
- `POSTGRES_DB`: `${{POSTGRES_DB}}` (the main database, e.g., `railway`)

3. The initialization script will automatically:
   - Connect to your existing PostGIS instance
   - Create the `flowise` database if it doesn't exist
   - Start Flowise with the new database

4. Both n8n and Flowise will use the same PostGIS instance but with separate databases

## 🚦 Queue Mode Configuration

Flowise supports queue mode for handling large numbers of predictions. This allows you to separate job submission from job execution and scale workers dynamically.

### Railway Deployment with Queue Mode

1. **Add Redis to your Railway environment:**
   - Deploy Redis from Railway's template marketplace to the same environment
   - Note the `RAILWAY_PRIVATE_DOMAIN` and `REDIS_PASSWORD` from the Redis service

2. **Configure Flowise main server (job submission):**
   ```env
   MODE=queue
   QUEUE_NAME=flowise-queue
   REDIS_HOST=${{RAILWAY_PRIVATE_DOMAIN}} # From your Redis service
   REDIS_PORT=6379
   REDIS_PASSWORD=${{REDIS_PASSWORD}} # From your Redis service
   ```

3. **Deploy Flowise worker(s):**
   - Deploy another instance of this Flowise template
   - Set the same Redis configuration as above
   - Set `MODE=worker` instead of `MODE=queue`
   - You can deploy multiple workers for parallel processing

### Local Development with Queue Mode

1. **Update your `.env` file:**
   ```env
   MODE=queue
   QUEUE_NAME=flowise-queue
   REDIS_HOST=redis
   REDIS_PORT=6379
   WORKER_CONCURRENCY=10000
   ```

2. **Start services with docker-compose:**
   ```bash
   docker-compose up -d
   ```

3. **To add a worker container**, create a new service in `docker-compose.yml`:
   ```yaml
   flowise-worker:
       build: .
       restart: always
       depends_on:
           postgis:
               condition: service_healthy
           redis:
               condition: service_healthy
       environment:
           - MODE=worker
           - WORKER_CONCURRENCY=10000
           # ... (copy other env vars from flowise service)
       volumes:
           - ~/.flowise:/root/.flowise
   ```

### Queue Configuration Options

- `MODE`: Set to `queue` for main server or `worker` for worker instances
- `QUEUE_NAME`: Name of the queue (default: `flowise-queue`)
- `WORKER_CONCURRENCY`: Number of parallel jobs per worker (default: 10000)
- `REMOVE_ON_AGE`: Remove completed jobs after X seconds (default: 86400 = 24 hours)
- `REMOVE_ON_COUNT`: Keep maximum X completed jobs (default: 10000)
- `ENABLE_BULLMQ_DASHBOARD`: Enable BullMQ dashboard for monitoring (default: false)

## 💁‍♀️ Example screenshots

![Flowise AI login screen!](https://zyugzloemocjcxmspsso.supabase.co/storage/v1/object/public/static-assets/flowise-login-screen.png "Flowise AI login screen")


![Flowise AI version screen!](https://zyugzloemocjcxmspsso.supabase.co/storage/v1/object/public/static-assets/flowise-version-screen.png "Flowise AI version screen")

![Flowise database!](https://zyugzloemocjcxmspsso.supabase.co/storage/v1/object/public/static-assets/flowise-database.jpg "Flowise database")



-----

# Start Flowise with Docker Compose (Local development)

## 💁‍♂️ Usage

1. Create `.env` file and specify the `PORT` (refer to `.env.example`)
2. `docker-compose up -d`
3. Open [http://localhost:3000](http://localhost:3000)
4. You can bring the containers down by `docker-compose stop`

## 🔒 Authentication

1. Create `.env` file and specify the `PORT`, `FLOWISE_USERNAME`, and `FLOWISE_PASSWORD` (refer to `.env.example`)
2. Pass `FLOWISE_USERNAME` and `FLOWISE_PASSWORD` to the `docker-compose.yml` file:
    ```
    environment:
        - PORT=${PORT}
        - FLOWISE_USERNAME=${FLOWISE_USERNAME}
        - FLOWISE_PASSWORD=${FLOWISE_PASSWORD}
    ```
3. `docker-compose up -d`
4. Open [http://localhost:3000](http://localhost:3000)
5. You can bring the containers down by `docker-compose stop`

## 🌱 Env Variables

If you like to persist your data (flows, logs, apikeys, credentials), set these variables in the `.env` file inside `docker` folder:

-   DATABASE_PATH=/root/.flowise
-   APIKEY_PATH=/root/.flowise
-   LOG_PATH=/root/.flowise/logs
-   SECRETKEY_PATH=/root/.flowise

Flowise also support different environment variables to configure your instance. Read [more](https://docs.flowiseai.com/environment-variables)



## Credit

- Inspired from [https://railway.app/template/pn4G8S](https://railway.app/template/pn4G8S), [https://github.com/FlowiseAI/Flowise/tree/main/docker](https://github.com/FlowiseAI/Flowise/tree/main/docker) and [https://github.com/HenryHengZJ/FlowiseAI-Railway/blob/main/Dockerfile](https://github.com/HenryHengZJ/FlowiseAI-Railway/blob/main/Dockerfile)