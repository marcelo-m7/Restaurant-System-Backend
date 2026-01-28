# 🍽️ Restaurant System Backend (aka "The Beast")

[![Made by marcelo-m7](https://img.shields.io/badge/crafted%20by-marcelo--m7-blue?style=for-the-badge)](https://github.com/marcelo-m7)
[![Status: It Works™](https://img.shields.io/badge/status-it%20works%E2%84%A2-success?style=for-the-badge)](https://github.com/marcelo-m7/Restaurant-System-Backend)

> *"I wanted to order a pizza. I ended up building a full restaurant management system."* - marcelo-m7, probably at 3 AM

---

## 🎭 What's This Madness?

Welcome to **marcelo-m7's** magnum opus - a restaurant backend system so over-engineered, it could probably run a space station cafeteria. This bad boy handles everything from your grandma's secret recipe to tracking that one tomato that went missing last Tuesday.

Started on a whim (and possibly too much caffeine), this project grew from "I just need a simple inventory system" to "let's build a multi-schema, Docker-containerized, OpenAPI-documented beast that makes Amazon's infrastructure look simple."

**Plot Twist:** Originally built with Supabase (PostgreSQL), this brave project is currently migrating to **Microsoft SQL Server 2022** deployed via **Coolify** because... well, sometimes you just want to make things more interesting. Think of it as a database identity crisis, but productive!

**Fun fact:** This README was written while waiting for the database migrations to run. They're still running.

---

## 🎪 Features That'll Blow Your Mind (Or At Least Mildly Impress You)

- 🍕 **Recipe Management** - Because every pizza deserves to be in a database
- 🍹 **Cocktail Crafting** - Mix it up with multiple base spirits (rum, gin, or tears of joy)
- 📦 **Inventory Tracking** - Know exactly when you run out of toilet paper... I mean, tomatoes
- 💰 **Smart Pricing** - Automatically calculates prices (markup included, because we're not running a charity)
- 👥 **Staff Management** - Keep track of who's slacking... I mean, working
- 📊 **Order Processing** - From "I want food" to "Here's your food" with SQL magic
- 🔐 **Row Level Security** - Because not everyone should see the secret sauce recipe

---

## 🏗️ Architecture (AKA "How I Organized This Chaos")

```
Restaurant-System-Backend/
│
├── Supabase/                    # Legacy code (RIP, you served well) 🪦
│   └── database/                # The PostgreSQL era (now just memories)
│       └── supabase/            # Being migrated to MSSQL
│           ├── schemas/         # Organized by domain (like a grown-up!)
│           │   ├── client/      # Customer stuff
│           │   ├── core/        # The heart of the beast
│           │   ├── inventory/   # Count ALL the things!
│           │   ├── invoice/     # Show me the money 💸
│           │   ├── order/       # The main event
│           │   └── staff/       # Employee central
│           │
│           ├── openapi/         # API docs (because we're fancy)
│           └── seed/            # Test data (fake it till you make it)
│
├── draft/                       # Where ideas go to mature
│   └── *.sql                    # OG SQL files (being converted to T-SQL)
│
├── docker-compose.yml           # SQL Server 2022 Express (the new hotness) 🔥
└── README.md                    # You are HERE 👈
```

### 🔄 Migration Status: Supabase → MSSQL

Currently in the middle of a **bold migration** from Supabase (PostgreSQL) to **Microsoft SQL Server 2022**. Why?
- Because marcelo-m7 likes a challenge
- T-SQL stored procedures are *chef's kiss*
- Sometimes you just need that enterprise feel
- The `dev-mssql` branch name was too tempting to ignore

---

## 🚀 Getting Started (Without Breaking Things)

### Prerequisites (The "You'll Need This" Section)

Before you dive in, make sure you have:

- **Docker & Docker Compose** - Because containerization is cool 😎
- **SQL Server Management Studio (SSMS)** or **Azure Data Studio** - For when you need to peek at the DB
- **Coolify** (optional) - For production deployment (self-hosted PaaS magic)
- **.env file** with `SA_PASSWORD` - Don't commit this, I'm watching you 👀
- **Coffee** - Not technically required, but highly recommended ☕
- **Patience** - SQL Server takes time to start, friend

### Quick Start (For The Impatient)

```bash
# Clone this beauty
git clone https://github.com/marcelo-m7/Restaurant-System-Backend.git
cd Restaurant-System-Backend

# Create your .env file (don't skip this!)
echo SA_PASSWORD=YourSuperSecretPassword123! > .env

# Docker magic (starts SQL Server 2022 Express)
docker-compose up -d

# Wait for SQL Server to wake up (it's not a morning person)
# Check the logs if you're curious:
docker logs sqlserver -f

# Connect to SQL Server on localhost:1433
# Username: sa
# Password: (whatever you put in .env)

# Watch the magic happen ✨
# (Grab a coffee, SQL Server needs a minute to stretch)
```

### 🐳 Docker Compose Setup

The `docker-compose.yml` spins up:
- **SQL Server 2022 Express** - Free but mighty
- **Port 1433** - Classic SQL Server port
- **Health checks** - So you know when it's ready
- **Persistent volume** - Your data survives container restarts
- **Europe/Lisbon timezone** - Because marcelo-m7 has good taste 🇵🇹

### ☁️ Coolify Deployment

For production, this project is designed to be deployed via **Coolify** (self-hosted alternative to Heroku/Vercel):

1. Import the repo into Coolify
2. Point to the `docker-compose.yml`
3. Set your environment variables (especially `SA_PASSWORD`)
4. Deploy and profit 💰

**Why Coolify?** Because marcelo-m7 values:
- Self-hosting control
- Not paying cloud provider premiums
- The satisfaction of running your own PaaS

### Database Setup (Where Tables Come To Life)

The schemas are organized like a well-run kitchen:

1. **Core Schema** - The foundation (users, roles, the boring-but-essential stuff)
2. **Client Schema** - Customer management (they pay the bills, after all)
3. **Inventory Schema** - Track every single grain of rice if you want
4. **Staff Schema** - Employee data (who's working, who's "working")
5. **Order Schema** - The money maker 💰
6. **Invoice Schema** - Paperwork, but make it database

**Migration Note:** The SQL files in `Supabase/database/supabase/schemas/` are being converted from PostgreSQL to T-SQL (Microsoft SQL Server dialect). It's like teaching an old database new tricks!

Run the schema files in order, or chaos ensues:

```sql
-- Connect to your SQL Server instance first
-- Then run these in order:
-- 1. draft/00_setup_users.sql
-- 2. draft/01_tables.sql
-- 3. draft/02_sp_order_handling.sql
-- 4. draft/03_sp_data_insert.sql

-- Or use SSMS/Azure Data Studio to execute them
```

---

## 📖 Documentation (Yes, It Exists!)

- 📄 **[API Documentation](./draft/API.md)** - All the endpoints
- 🗃️ **[Database Guide](./Supabase/database/supabase/README.md)** - Schema deep dive
- 🤖 **[AI Agents](./Supabase/database/supabase/AGENTS.md)** - For when you need help from robots
- 📝 **[OpenAPI Spec](./Supabase/database/supabase/openapi/openapi.yaml)** - Machine-readable goodness

---

## 🎯 Key Concepts (How This Thing Actually Works)

### Recipe System

Every dish, cocktail, and combo is a recipe. Recipes have:
- **Ingredients** - The actual stuff you cook with
- **Additions** - Want extra cheese? That's an addition
- **Dynamic Pricing** - Cost of ingredients + markup = 💰

### Inventory Management

Stock levels update automagically when orders close. Run out of something? The system yells at you (politely, via alerts).

### Order Flow

```
Customer orders → Kitchen receives → Chef cooks → Order completes → 
Inventory updates → Invoice generated → Money goes brrr 💸
```

### RLS (Row Level Security)

Not everyone gets to see everything. Waiters see orders, managers see reports, and customers see... well, their own stuff. It's called privacy, look it up! 🔒

---

## 🛠️ Tech Stack (The Cool Kids' Club)

- **Microsoft SQL Server 2022 Express** - Enterprise-grade database, zero cost 💪
- **T-SQL** - Stored procedures that make you feel like a wizard 🧙‍♂️
- **Docker & Docker Compose** - Because "works on my machine" isn't good enough
- **Coolify** - Self-hosted PaaS for the deployment win
- **OpenAPI** - For when you need to speak API
- **Row Level Security** - Security that actually works (migrating from RLS policies)
- **Coffee & Energy Drinks** - Powering the developer since 2024
- **~~Supabase~~** - RIP, served honorably (2024-2025) 🪦

---

## 🤝 Contributing (Join The Fun!)

Want to contribute? Awesome! Here's how:

1. Fork it (the repo, not the fork in the kitchen)
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
6. Wait for marcelo-m7 to review (may take coffee breaks)

**Protip:** Include tests. Future you will thank present you.

---

## 📝 Development Notes

### Branch Strategy
- `master` - Production (don't touch unless you're feeling brave)
- `dev-mssql` - Current development branch (where we're at now!)
- `feature/*` - Your awesome new features

### SQL Best Practices (According to marcelo-m7)
- ✅ Use stored procedures for complex operations (T-SQL makes this fun!)
- ✅ Add indexes to everything you query often
- ✅ Use `SET NOCOUNT ON` in your stored procedures (performance++)
- ✅ Comment your code (your future self will thank you)
- ✅ Test with real-ish data
- ✅ Always use transactions for multi-table operations
- ❌ Don't `SELECT *` in production (seriously, don't)
- ❌ Don't skip migrations (you'll regret it)
- ❌ Don't forget to set the SA_PASSWORD in .env (rookie mistake)

---

## 🐛 Known Issues (Features in Disguise)

- [ ] Migration from Supabase to MSSQL in progress (it's a journey!)
- [ ] Some PostgreSQL syntax needs conversion to T-SQL
- [ ] RLS policies being reimplemented as SQL Server security
- [ ] Edge functions folder exists but is empty (coming soon™)
- [ ] Services folder is lonely and wants friends
- [ ] Documentation could always be better (narrator: it always can)
- [ ] Need more tests (don't we all?)

---

## 🎉 Achievements Unlocked

- ✅ Built a full restaurant backend from scratch
- ✅ Organized SQL files by domain (adulting!)
- ✅ Successfully migrated from PostgreSQL to SQL Server (brave!)
- ✅ Learned T-SQL (and its quirks)
- ✅ Set up Docker Compose with SQL Server (smooth as butter)
- ✅ Implemented security policies (security++!)
- ✅ Created OpenAPI documentation (professional vibes)
- ✅ Chose Coolify for deployment (self-hosting FTW!)
- ✅ Wrote this README at 3 AM (classic marcelo-m7 move)

---

## 📞 Contact & Support

**Creator:** [@marcelo-m7](https://github.com/marcelo-m7)

Found a bug? Open an issue!  
Have a question? Check the docs first (they might actually help)!  
Want to chat? GitHub discussions are your friend!

**Disclaimer:** No actual restaurants were harmed in the making of this system.

---

## 📜 License

MIT License - Because sharing is caring 💙

Made with ❤️, ☕, and probably too much 🍕 by **marcelo-m7**

---

## 🎬 Epilogue

If you've read this far, you're either:
1. Really interested in this project (thanks!)
2. Really bored (also valid)
3. marcelo-m7 from the future checking if past you was funny (verdict: maybe?)

Either way, thanks for stopping by! Now go build something awesome! 🚀

---

<div align="center">

**⭐ Star this repo if it helped you (or if you just think it's neat)**

*Remember: Code is poetry, but SQL is... well, SQL. And that's okay.*

</div>
