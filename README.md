# chefs-quest

A cooking game app where you unlock recipes, earn XP, and share your dishes with friends.

## Project Structure

```
chefs-quest/
├── app/          # Flutter app
├── backend/      # FastAPI backend
├── docker-compose.yml
└── README.md
```

## Setup

### Prerequisites
- Flutter SDK
- Python 3.11+
- Docker & Docker Compose

### Flutter App

```bash
cd app
flutter pub get
flutter run
```

### FastAPI Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

### Local Database (PostgreSQL)

```bash
docker-compose up -d
```
