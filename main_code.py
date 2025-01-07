import asyncio
from config import config
import asyncpg

async def connect():
    try:
        # Load database configuration from ini file
        params = config()

        # Connect to the PostgreSQL database
        print('Connecting to the PostgreSQL database...')
        conn = await asyncpg.connect(
            host=params['host'],
            database=params['database'],
            user=params['user'],
            password=params['password']
        )

        # Execute a simple query
        version = await conn.fetchval("SELECT version();")
        print(f"PostgreSQL version: {version}")

        # Close the connection
        await conn.close()
        print('Database connection closed.')
    except Exception as error:
        print(f"Error: {error}")

if __name__ == "__main__":
    asyncio.run(connect())
