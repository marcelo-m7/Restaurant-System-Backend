# Boteco Pro Frontend

This is the React frontend for the **Boteco Pro** restaurant management app.

## Getting Started

```bash
npm install
npm run dev
```

Open `http://localhost:5173` in your browser.

## Environment Variables

Copy `.env.example` to `.env` if you want to preconfigure the API settings. The
`VITE_API_TOKEN` variable is used as the `Authorization` header for requests and
`VITE_API_BASE_URL` can define the default backend URL.

## Agents Guidance

See `AGENTS.md` for instructions on how to contribute and the project goals.

## Switching Between Mock and API Data

By default the app uses mock JSON files located in `src/mocks/`. Click the **Conectar** button and enter the backend URL to fetch data from the API instead.

## Management Module

The `/gestao` route shows a simple list of employees (funcionários) using mock data or the configured API. Use this page to experiment with management features.
