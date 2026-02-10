**Purpose**
- **Scope**: Quick, actionable guidance for AI coding agents to be productive in this repo.
- **Goal**: Describe the architecture, runtime workflows, important patterns, and concrete code examples to avoid guesswork.

**Big Picture**
- **Framework**: The app is built with `reflex` (see `requirements.txt`) — a Python UI framework where pages and components are built with `rx.*` primitives (e.g. `rx.el.div`, `rx.box`). The main entry is `app/app.py` which composes pages and plugs in services.
- **Auth & Frontend**: Authentication is handled via `reflex-clerk-api` (wrapped in `app/app.py` using `clerk.wrap_app`). Protected pages are registered with `on_load=clerk.protect`.
- **Backend services**: Supabase is used as the primary DB via `app/services/supabase_client.py`. There is a small internal FastAPI app for provisioning (`app/api/provision.py`) which is attached to the Reflex app (`app.api = api_app`).

**Runtime / Developer workflows**
- **Local dev (frontend + backend)**: Run the Reflex dev server: `reflex run` (the repo expects Reflex CLI). For backend-only runs (e.g. on servers) use `reflex run --env prod --backend-only --backend-port 8000` as shown in `Dockerfile`.
- **Export frontend static bundle**: Build and export the static frontend via `reflex export frontend`. If deploying static assets to a different host, set `API_URL` to your backend and follow the comment block in `Dockerfile`.
- **Docker**: The `Dockerfile` contains a multi-stage build and expects `reflex db migrate` to be applied before starting if an `alembic` folder exists. Use `docker build --platform=linux/amd64 -t boteco .` when building on non-amd64 hosts.

**Important environment variables**
- `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` (or `SUPABASE_KEY`) — required by `app/services/supabase_client.py` and `app/api/provision.py`.
- `CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY` — used by the Clerk wrapper in `app/app.py`.
- `PORT` — optional runtime port used by the Docker container (defaults to 8000 in `Dockerfile`).

**Key patterns & conventions (repo-specific)**
- **Pages and routing**: Pages live under `app/pages/*` and are registered centrally in `app/app.py` via `app.add_page(<page_fn>, route="/path", on_load=...)`.
- **State management**: App state classes extend `rx.State` and live in `app/states/*.py` (e.g. `OnboardingState`). Event handlers are annotated with `@rx.event` and may `yield` to show progress or perform async work. Example pattern in `app/states/onboarding_state.py`:
  - `@rx.event
    async def handle_personal_submit(self, form_data: dict):
        ...
        response = await supabase_client.upsert_user(user_data)
        yield rx.redirect("/onboarding/step-2-business")`
- **Service singletons**: Services instantiate module-level singletons (e.g. `supabase_client = SupabaseClient()` in `app/services/supabase_client.py`). Use the exported instance rather than creating new clients.
- **Internal API & provisioning**: Provisioning of tenant schemas is done via the FastAPI endpoint `POST /api/provision_org` in `app/api/provision.py`. The Supabase admin key is required; the internal call is initiated from `SupabaseClient.provision_schema` (it calls `http://localhost:8000/api/provision_org`). When running locally ensure the backend is reachable at that address/port.
- **Styling**: Global tokens and CSS helpers live in `app/theme.py` and `app/styles.py`. The code uses utility classes (Tailwind-like) in component definitions; prefer using `styles.surface()` and `styles.section_container()` helpers when adding layout.

**Editing guidelines for agents**
- When adding a new page: create `app/pages/...py`, export a function that returns an `rx.Component`, then import and register it in `app/app.py` with `app.add_page(...)`.
- For auth-protected pages, register with `on_load=clerk.protect` (see onboarding pages in `app/app.py`).
- When adding server-side endpoints, add a new router under `app/api/*` and then assign it in `app/app.py` via `app.api = <fastapi_app>` so Reflex serves it alongside the frontend.
- Use the existing `SupabaseClient` singleton for DB actions; follow the upsert/create flows (example in `onboarding_state.py`).
- Preserve the `@rx.event`/`yield` pattern for long-running or async events to keep the UI responsive and correctly update state/toasts/redirects.

**Common pitfalls to avoid**
- Do not call Supabase RPCs or admin actions without the service role key — `provision_org` requires `SUPABASE_SERVICE_ROLE_KEY`.
- The provisioning endpoint expects `boteco_username` to be alphanumeric or include `_` (see validation in `app/api/provision.py`). Keep username generation consistent with `OnboardingState` logic.
- The internal provisioning call uses `http://localhost:8000` by default. If the API is deployed to another host, update `SupabaseClient.provision_schema` accordingly.

**Quick examples**
- Register a page (in `app/app.py`):
  `app.add_page(my_page, route='/my-page', on_load=clerk.protect)`
- Use the Supabase singleton:
  `from app.services.supabase_client import supabase_client`
  `await supabase_client.upsert_user(user_data)`

**Where to look for more context**
- `app/app.py` — app wiring and page registration.
- `app/states/onboarding_state.py` — canonical example of state, events, DB flow, and provisioning.
- `app/services/supabase_client.py` — Supabase client patterns and internal provisioning call.
- `app/api/provision.py` — FastAPI provisioning endpoint and validation.
- `Dockerfile` and `requirements.txt` — build/runtime notes and required packages.

If anything in these sections is unclear or you want more detail (e.g., tests, CI commands, or examples for adding a feature), tell me what to expand and I will iterate.
