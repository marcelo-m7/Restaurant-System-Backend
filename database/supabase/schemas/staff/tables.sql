-- ============================================
-- staff/tables.sql
-- ============================================

create table staff.employee (
    employee_id serial primary key,
    name text,
    role text,
    hourly_rate numeric(10,2)
);

create table staff.shift (
    shift_id serial primary key,
    employee_id integer references staff.employee(employee_id),
    start_time time not null,
    end_time time not null,
    date date not null,
    notes text
);
