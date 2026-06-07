# Café Fausse Website

Café Fausse is a responsive restaurant website built with React (JavaScript/JSX), Flask, and PostgreSQL. The site includes five main pages—**Home**, **Menu**, **Reservations**, **About Us**, and **Gallery**—and supports online reservations and newsletter signups.

This project is currently set up for **local development only**:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5001`
- Database: PostgreSQL on `localhost:5432`

## Features

- Responsive design for mobile, tablet, and desktop
- Five main pages:
  - Home
  - Menu
  - Reservations
  - About Us
  - Gallery
- Writable features:
  - Online reservations
  - Newsletter signup (with duplicate handling)
- Easy-to-update content via JSON:
  - Menu items
  - Awards
  - Reviews

## Tech Stack

| Component      | Technology                         |
|----------------|------------------------------------|
| Frontend       | React 18 + JavaScript (JSX)        |
| Build tool     | Create React App (`react-scripts`) |
| Styling        | CSS Flexbox & Grid                 |
| Routing        | React Router DOM v6                |
| HTTP client    | Axios                              |
| Backend        | Flask REST API                     |
| Database       | PostgreSQL + SQLAlchemy            |
| Data files     | JSON (menu, awards, reviews)       |
| Email (optional) | Development-only newsletter verification |

### Key Dependencies

**Frontend (`reactjs-client`)**

- `react`: 18.2.0
- `react-dom`: 18.2.0
- `react-router-dom`: 6.6.0
- `axios`: 1.2.1
- `react-scripts`: 5.0.1
- Testing libraries:
  - `@testing-library/react`
  - `@testing-library/jest-dom`
  - `@testing-library/user-event`

**Backend (`Flask-backend`)**

- `flask`
- `flask-cors`
- `Flask-SQLAlchemy`
- `Flask-WTF`
- `psycopg2-binary`
- `python-dotenv`
- `SQLAlchemy`
- `WTForms`
- `email-validator`

(See `Flask-backend/requirements.txt` for the full list.)

## Business Rules

- Reservations are **2 hours** long internally.
- Reservation start times are in **15-minute increments**.
- Time slots must:
  - Fit within opening hours
  - Not start less than **2 hours before closing**
- **Walk-up tables** are excluded from reservations.
- Table allocation must match **party size**.
- Newsletter signup:
  - Updates existing records if the email already exists (no duplicates).

## Prerequisites

- **macOS** (development instructions are for Mac OS X)
- **Node.js 22+**
- **npm**
- **Python 3**
- **PostgreSQL**
- **Git**
- **GitHub CLI (`gh`)** (optional, for authentication)

You can install the required tools via Homebrew:

```bash
brew install git gh node python postgresql
```

Check versions:

```bash
git --version
gh --version
node -v
npm -v
python3 --version
psql --version
```


## Quick Start (Local Development)

After completing the full setup (see **Installation \& Local Setup**), you can start the project with:

1. Open **two Terminal** windows.
2. **Backend (Flask)** – in the first terminal:

```bash
cd cafefausse/Flask-backend
source venv/bin/activate   # if you haven't activated yet
brew services start postgresql   # if PostgreSQL is not running
flask run --host localhost --port 5001 --debugger
```

3. **Frontend (React)** – in the second terminal:

```bash
cd cafefausse/reactjs-client
npm run start
```

4. Open your browser and navigate to:

```text
http://localhost:3000
```


You should see the Café Fausse homepage. Navigate to the **Reservation** page to test reservations.

## Installation \& Local Setup (macOS)

All services run locally:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5001`
- Database: PostgreSQL on `localhost:5432`


### Step 1 – Install Tools

1. Open a **Terminal** window.
2. Install **Homebrew** if you don't have it.
3. Install developer tools:

```bash
brew install git gh node python postgresql
```


### Step 2 – Get Source Code

1. Navigate to your repositories folder:

```bash
cd /your-repo
```

2. Authenticate with GitHub (if needed):

```bash
gh auth login
```

Follow the prompts to login via a web browser or token.
3. Clone the repository:

```bash
git clone https://github.com/chuckpib/cafefausse.git
cd cafefausse
```


### Step 3 – Set Up Flask Backend

1. Navigate to the Flask backend folder:

```bash
cd Flask-backend
```

2. Create a Python virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

3. Upgrade `pip` and install dependencies:

```bash
python -m pip install --upgrade pip
pip install -r requirements.txt
```

4. Ensure PostgreSQL is running:

```bash
brew services start postgresql
```

5. Start Flask:

```bash
flask run --host localhost --port 5001 --debugger
```

The backend API will run at `http://localhost:5001`.

### Step 4 – Set Up React Frontend

1. Open a **new Terminal** window.
2. Navigate to the React client folder:

```bash
cd reactjs-client
```

3. Install dependencies:

```bash
npm install
```

4. Start the React development server:

```bash
npm run start
```

The frontend will run at `http://localhost:3000`.

> **Note:** You need **Node version 22+** for this to run.

### Step 5 – Create and Restore the Database

1. In the `Flask-backend` folder, ensure PostgreSQL is running:

```bash
brew services start postgresql
```

2. Create the database:

```bash
createdb Cafe_Fausse_DB
```

3. Open a SQL session and create the `postgres` user and password:

```bash
psql -d postgres
```

Inside `psql`:

```sql
CREATE ROLE postgres WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD 'Cafe_Fausse2026!';
\q
```

4. Restore the database backup:

```bash
psql -U <your-postgresql-userid> -d Cafe_Fausse_DB -f db_backup.sql
```

5. Configure database connection:
    - Create or edit `.env` in `Flask-backend`:

```env
SECRET_KEY=your_secret_key_here
DATABASE_URL=postgresql://postgres:Cafe_Fausse2026!@localhost:5432/Cafe_Fausse_DB
```

    - In `config.py` (production / shared config):

```python
from dotenv import load_dotenv
import os

load_dotenv()

class Config:
    DATABASE_URL = os.getenv(
        'DATABASE_URL',
        'postgresql://postgres:CafeFausse2026!@localhost:5432/Cafe_Fausse_DB'
    )
    SECRET_KEY = os.getenv(
        'SECRET_KEY',
        'dev-secret-key-change-in-production'
    )

config = Config()
```

    - Modify the connection settings in the source code to match your PostgreSQL port (typically `5432`, `5433`, or `5434`). In this project, we use **5432**.
6. (Optional but recommended) Change the default password for security:

```bash
psql -U postgres -h localhost -d Cafe_Fausse_DB
```

Inside `psql`:

```sql
ALTER USER postgres WITH PASSWORD 'yournewpasswordhere!';
\q
```

Update `.env` and/or `config.py` with the new password and restart Flask if needed.

### Step 6 – Verify It's Working

1. Open your browser and navigate to:

```text
http://localhost:3000
```

2. Go to the **Reservation** page.
3. Try to make a reservation:
    - Select a date and a party size.
    - It should return some results or a message saying there is no availability.
4. If nothing is displayed and no time is listed:
    - Check your **port settings** (frontend: 3000, backend: 5001, DB: 5432).
    - Check your **password** and `.env`/`config.py` configuration.

## Available Scripts

### Frontend (Create React App)

In the `reactjs-client` folder:

```bash
npm run start      # Start development server at http://localhost:3000
npm run build      # Build for production into reactjs-client/build
npm run test       # Run tests (test framework is configured but not used in this project)
npm run eject      # Eject from Create React App (if you want full control)
```

This project uses ESLint via the `react-app` config:

- ESLint configuration is in `package.json` under `eslintConfig`:

```json
"eslintConfig": {
  "extends": ["react-app", "react-app/jest"]
}
```

- You're developing in **VS Code**, which can integrate with this ESLint setup via the VS Code ESLint extension.

> Tests are configured but not actively used in this project.

### Backend (Flask)

In the `Flask-backend` folder:

```bash
flask run --host localhost --port 5001 --debugger
```


## Project Structure

```text
cafefausse/
├── AI-Tooling.md
├── Flask-backend/
│   ├── app.py
│   ├── config.py
│   ├── db_backup.sql
│   ├── demo_data.sql
│   ├── forms.py
│   ├── requirements.txt
│   ├── static/
│   │   └── styles.css
│   └── templates/
│       └── (HTML templates: home.html, about.html, admin.html, etc.)
├── reactjs-client/
│   ├── package.json
│   ├── public/
│   │   └── (index.html, manifest.json, icons, etc.)
│   └── src/
│       ├── App.js
│       ├── App.css
│       ├── index.js
│       ├── index.css
│       ├── components/
│       ├── data/
│       │   ├── awards.json
│       │   ├── menu.json
│       │   └── reviews.json
│       ├── services/
│       └── assets/
└── README.md
```


## Configuration

### Environment Variables

#### Backend (Flask)

In `Flask-backend/.env`:

- `SECRET_KEY`: Flask secret key.
- `DATABASE_URL`: PostgreSQL connection string.

Example:

```env
SECRET_KEY=your_secret_key_here
DATABASE_URL=postgresql://postgres:Cafe_Fausse2026!@localhost:5432/Cafe_Fausse_DB
```


#### Frontend (React)

This project currently uses a local backend at `http://localhost:5001`. If you add environment variables in the frontend (e.g., API base URL), they should be prefixed with `REACT_APP_`:

```env
REACT_APP_API_BASE_URL=http://localhost:5001
```

For development, create a `.env` file in `reactjs-client` with your environment variables (do not commit secret values).

## JSON Data Files

Menu, awards, and reviews are stored in JSON files in the **frontend** `src/data` folder and loaded by the React app (or via the backend, depending on your implementation). These are designed to be easy to update without changing code.

Path:

```text
reactjs-client/src/data/
  awards.json
  menu.json
  reviews.json
```


### `awards.json`

Structure:

```json
{
  "awards": [
    {
      "name": "Culinary Excellence Award",
      "year": "- 2022"
    },
    {
      "name": "Restaurant of the Year",
      "year": "- 2023"
    },
    {
      "name": "Best Fine Dining Experience",
      "source": "- Foodie Magazine",
      "year": 2023
    }
  ]
}
```

Fields:

- `name`: Award name (string)
- `year`: Award year (string or number)
- `source`: Optional source or magazine (string)


### `menu.json`

Structure:

```json
{
  "menu": {
    "Starters": [
      {
        "name": "Bruschetta",
        "description": "Fresh tomatoes, basil, olive oil, and toasted baguette slices",
        "price": 8.5
      },
      {
        "name": "Caesar Salad",
        "description": "Crisp romaine with homemade Caesar dressing",
        "price": 9.0
      }
    ],
    "Main Courses": [
      {
        "name": "Grilled Salmon",
        "description": "Served with lemon butter sauce and seasonal vegetables",
        "price": 22.0
      },
      {
        "name": "Ribeye Steak",
        "description": "12 oz prime cut with garlic mashed potatoes",
        "price": 28.0
      },
      {
        "name": "Vegetable Risotto",
        "description": "Creamy Arborio rice with wild mushrooms",
        "price": 18.0
      }
    ],
    "Desserts": [
      {
        "name": "Tiramisu",
        "description": "Classic Italian dessert with mascarpone",
        "price": 7.5
      },
      {
        "name": "Cheesecake",
        "description": "Creamy cheesecake with berry compote",
        "price": 7.0
      }
    ],
    "Beverages": [
      {
        "name": "Red Wine (Glass)",
        "description": "A selection of Italian reds",
        "price": 10.0
      },
      {
        "name": "White Wine (Glass)",
        "description": "Crisp and refreshing",
        "price": 9.0
      },
      {
        "name": "Craft Beer",
        "description": "Local artisan brews",
        "price": 6.0
      },
      {
        "name": "Espresso",
        "description": "Strong and aromatic",
        "price": 3.0
      }
    ]
  }
}
```

Fields per item:

- `name`: Dish name (string)
- `description`: Short description (string)
- `price`: Price in dollars (number)

Categories:

- `Starters`
- `Main Courses`
- `Desserts`
- `Beverages`


### `reviews.json`

Structure:

```json
{
  "reviews": [
    {
      "quote": "Exceptional ambiance and unforgettable flavors.",
      "source": "- Gourmet Review"
    },
    {
      "quote": "A must-visit restaurant for food enthusiasts.",
      "source": "- The Daily Bite"
    }
  ]
}
```

Fields:

- `quote`: Review text (string)
- `source`: Review source (string)

To update content:

- Edit the JSON files directly in `reactjs-client/src/data/`.
- Restart the React development server if changes don't appear automatically.
- No code changes are required.


## Local Deployment Summary

This project is configured for **local development only**:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5001`
- Database: PostgreSQL on `localhost:5432`

No cloud deployment is configured yet. All services must be running on your machine for the app to work.

## Troubleshooting

### Frontend not loading at `http://localhost:3000`

- Ensure the React server is running:

```bash
cd reactjs-client
npm run start
```

- Check that **Node 22+** is installed:

```bash
node -v
```

- If port 3000 is already in use:
    - React will prompt you to use a different port.
    - Or stop the other process using port 3000.


### Backend API not responding at `http://localhost:5001`

- Ensure Flask is running:

```bash
cd Flask-backend
source venv/bin/activate
flask run --host localhost --port 5001 --debugger
```

- Check that the virtual environment is activated and `requirements.txt` was installed:

```bash
pip list
```

- Ensure no other process is using port 5001.


### PostgreSQL not running or connection errors

- Ensure PostgreSQL service is running:

```bash
brew services start postgresql
```

- Check PostgreSQL status:

```bash
brew services list
```

- Verify the database exists:

```bash
createdb Cafe_Fausse_DB
```

- Verify you can connect:

```bash
psql -U postgres -d Cafe_Fausse_DB
```

- Check your `.env` and `config.py`:
    - `DATABASE_URL` must match your username, password, host, port, and DB name:

```env
DATABASE_URL=postgresql://postgres:Cafe_Fausse2026!@localhost:5432/Cafe_Fausse_DB
```


### Wrong password or permission errors

- If you changed the `postgres` password, update:
    - `.env`
    - `config.py`
    - Any other place where `DATABASE_URL` is defined.
- To reset the password:

```bash
psql -U postgres -h localhost -d Cafe_Fausse_DB
```

Then:

```sql
ALTER USER postgres WITH PASSWORD 'yournewpasswordhere!';
\q
```


### Reservations page shows no data or errors

- Confirm the backend is running and reachable:
    - Try visiting a backend endpoint directly in the browser or with `curl`.
- Check the browser console for errors:
    - Open DevTools (usually `Cmd + Option + J` on macOS).
    - Look for failed requests to `http://localhost:5001`.
- Verify:
    - The database is restored from `db_backup.sql`.
    - The port in `DATABASE_URL` is correct (5432).
    - The Flask app is configured to connect to the correct database.


### CORS errors (frontend can't call backend)

- Ensure `flask-cors` is installed:

```bash
pip install flask-cors
```

- In your Flask app, configure CORS to allow requests from `http://localhost:3000`:

```python
from flask_cors import CORS

CORS(app, origins=["http://localhost:3000"])
```


### ESLint warnings in VS Code

- Install the **ESLint extension** for VS Code.
- Ensure your project's `eslintConfig` is using `react-app` (already configured in `package.json`).
- Some warnings are normal during development; focus on errors that prevent the app from running.


### JSON data not updating in the frontend

- Ensure you're editing the files in the correct location:
    - `reactjs-client/src/data/awards.json`
    - `reactjs-client/src/data/menu.json`
    - `reactjs-client/src/data/reviews.json`
- Restart the React development server:

```bash
npm run start
```

- Check that the components are correctly importing or fetching these JSON files.


## Credits

**MAC Consulting:**
Mary English, Aurelie Eybalin, and Chuck Ma


