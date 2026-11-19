-- Skema Supabase / PostgreSQL untuk Vox Angelica
create type role_t as enum ('BPH','ANGGOTA');
create type att_t as enum ('HADIR','IZIN','SAKIT');
create type kas_t as enum ('BELUM','MENUNGGU','LUNAS','DITOLAK');

create table profiles (            -- id = auth.users.id (Supabase Auth)
  id uuid primary key references auth.users on delete cascade,
  name text not null, email text unique not null, phone text,
  role role_t not null default 'ANGGOTA', status text default 'Aktif',
  created_at timestamptz default now());

create table rehearsals (
  id uuid primary key default gen_random_uuid(),
  title text not null, date date not null,
  status text not null default 'TERJADWAL' check (status in ('TERJADWAL','BERLANGSUNG','SELESAI')));

create table attendance (
  rehearsal_id uuid references rehearsals on delete cascade,
  member_id uuid references profiles on delete cascade,
  status att_t not null, checked_at timestamptz default now(),
  primary key (rehearsal_id, member_id));

create table kas_payments (
  member_id uuid references profiles on delete cascade,
  month date not null,              -- tanggal 1 tiap bulan
  status kas_t not null default 'BELUM',
  proof_url text, verified_by uuid references profiles, verified_at timestamptz,
  primary key (member_id, month));

create table songs (
  id uuid primary key default gen_random_uuid(),
  title text not null, note text, file_url text not null,
  uploaded_by uuid references profiles, created_at timestamptz default now());

create table agenda (
  id uuid primary key default gen_random_uuid(),
  type text check (type in ('Latihan','Pelayanan','Konser')),
  title text not null, date date not null, place text);

create table announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null, body text not null, created_by uuid references profiles, created_at timestamptz default now());

create table social_funds (
  id uuid primary key default gen_random_uuid(),
  kind text check (kind in ('DUKA','SAKIT')), recipient text not null,
  note text, visit_date date, amount int not null);   -- 20000 duka, 10000 sakit

create table social_contributions (
  fund_id uuid references social_funds on delete cascade,
  member_id uuid references profiles on delete cascade,
  paid boolean default false, paid_at timestamptz,
  primary key (fund_id, member_id));

-- Bucket Storage: "proofs" (bukti kas, private) dan "songs" (partitur).
-- Aktifkan Row Level Security: anggota hanya boleh insert/baca kas_payments miliknya;
-- hanya role BPH yang boleh update status, insert songs/agenda/announcements/social_*.
