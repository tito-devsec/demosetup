#!/usr/bin/env bash
# LOCAL-ONLY demo scaffolding for the "MedCore Family Clinic" scenario.
# Deliberately excluded from the PreRan repository via .gitignore -
# PreRan is a general-purpose tool and this is presentation scaffolding
# for one event, not a feature of the product. Never commit this file.
#
# ALL data generated below is synthetic, invented by this script at run
# time. Nothing here is a real person, a real record, or a real secret.
#
# One command does everything: seeds ~95 fake files and a seeded
# Postgres database across 5 tables (~95 rows), wires PreRan's engine
# and preran-cli layers to actually watch/protect it, then sits waiting
# and tailing logs so you can trigger your ransomware simulator in
# another terminal and watch the reaction live.
set -euo pipefail

COMPANY="MedCore Family Clinic"
ROOT="/srv/medcore"
DB_NAME="medcore_clinic"
DB_USER="medcore_app"
DB_PASS="DemoPass_$(tr -dc A-Za-z0-9 </dev/urandom | head -c 10)"

FIRST_NAMES=(Alicia Marcus Priya Tomas Sarah James Wanjiru Diego Fatima Noah Elena Kwame Yuki Omar Ingrid Hassan Chloe Viktor Amara Liam Sofia Ravi Nadia Ethan Mei Karim Freya Tunde Isabel Dmitri)
LAST_NAMES=(Nguyen Ferreira Chandran Vukovic Kim Ortiz Karanja Silva Haddad Bennett Petrov Mensah Tanaka Farouk Larsen Ali Dubois Ivanov Okafor Murphy Rossi Iyer Hassan Cole Zhang Aziz Andersen Adeyemi Cruz Sokolov)
DIAGNOSES=("Hypertension" "Type 2 Diabetes" "Asthma" "Migraine" "Hypothyroidism" "Anxiety Disorder" "Osteoarthritis" "GERD" "Eczema" "Seasonal Allergies")
ROLES=("Physician" "Nurse Practitioner" "Office Manager" "Billing Clerk" "Lab Technician" "IT Administrator" "Receptionist" "Physical Therapist")

echo "==> Setting up LOCAL-ONLY demo file server for: ${COMPANY}"
mkdir -p "$ROOT"/{patient_records,billing,hr,it,backups,shared,lab_results,insurance_claims,legal,vendor_contracts}
chmod -R 750 "$ROOT"

name_at() { local i=$1; echo "${FIRST_NAMES[$((i % ${#FIRST_NAMES[@]}))]} ${LAST_NAMES[$((i % ${#LAST_NAMES[@]}))]}"; }
ssn_at() { printf "000-%02d-%04d" "$(( (10#$1 * 7 + 11) % 99 ))" "$(( (10#$1 * 137 + 4001) % 9999 ))"; }

echo "==> Generating patient_records/ (25 files)"
for i in $(seq -w 1 25); do
  n="$(name_at "$((10#$i))")"
  cat > "$ROOT/patient_records/patient_$i.json" <<EOF
{
  "patient_id": "P$i",
  "name": "$n",
  "dob": "19$(( 60 + (10#$i % 35) ))-0$(( 1 + (10#$i % 9) ))-1$(( (10#$i % 8) ))",
  "ssn": "$(ssn_at "$i")",
  "diagnosis": "${DIAGNOSES[$((10#$i % ${#DIAGNOSES[@]}))]}",
  "insurance_id": "INS-$(( 80000 + 10#$i ))"
}
EOF
done

echo "==> Generating billing/ (20 files)"
for i in $(seq -w 1 20); do
  cat > "$ROOT/billing/invoice_$i.csv" <<EOF
invoice_id,patient_id,amount,card_last4,status
INV-4$i,P$(( 1 + (10#$i % 25) )),$(( (10#$i * 37 % 900) + 25 )).00,$(( 1000 + 10#$i * 111 % 8999 )),$([ $((10#$i % 3)) -eq 0 ] && echo pending || echo paid)
EOF
done

echo "==> Generating hr/ (10 files)"
for i in $(seq -w 1 10); do
  n="$(name_at "$((10#$i + 50))")"
  cat > "$ROOT/hr/employee_$i.csv" <<EOF
emp_id,name,role,salary,ssn
E$i,$n,${ROLES[$((10#$i % ${#ROLES[@]}))]},$(( 55000 + 10#$i * 3500 )),$(ssn_at "$((10#$i + 50))")
EOF
done

echo "==> Generating lab_results/ (10 files)"
for i in $(seq -w 1 10); do
  cat > "$ROOT/lab_results/labresult_$i.txt" <<EOF
[FAKE] Lab result - patient P$(( 1 + (10#$i % 25) ))
Test: $([ $((10#$i % 2)) -eq 0 ] && echo "CBC panel" || echo "Lipid panel")
Result: within normal range
EOF
done

echo "==> Generating insurance_claims/ (8 files)"
for i in $(seq -w 1 8); do
  cat > "$ROOT/insurance_claims/claim_$i.txt" <<EOF
[FAKE] Insurance claim CLM-$i
Patient: P$(( 1 + (10#$i % 25) ))
Status: $([ $((10#$i % 2)) -eq 0 ] && echo "approved" || echo "under review")
EOF
done

echo "==> Generating vendor_contracts/ (5 files)"
for i in 1 2 3 4 5; do
  cat > "$ROOT/vendor_contracts/contract_$i.txt" <<EOF
[FAKE] Vendor services contract #$i - $COMPANY
Term: 12 months, auto-renew
EOF
done

echo "==> Generating legal/, it/, backups/, shared/ (16 files)"
cat > "$ROOT/legal/hipaa_notice.txt" <<'EOF'
[FAKE] HIPAA Notice of Privacy Practices - demo content only.
EOF
cat > "$ROOT/legal/breach_response_plan.txt" <<'EOF'
[FAKE] Incident/breach response plan - demo content only.
EOF
cat > "$ROOT/legal/consent_form_template.txt" <<'EOF'
[FAKE] Patient consent form template - demo content only.
EOF
cat > "$ROOT/legal/compliance_policy.txt" <<'EOF'
[FAKE] Internal compliance policy - demo content only.
EOF
cat > "$ROOT/it/network_diagram_internal.txt" <<'EOF'
[FAKE] Internal network map - MedCore Family Clinic
Core switch: 10.10.0.1
EHR DB server: 10.10.0.20 (PostgreSQL, medcore_clinic)
Backup NAS: 10.10.0.40
EOF
cat > "$ROOT/it/passwords_backup.txt" <<'EOF'
[FAKE] legacy password export - rotate immediately
admin / DemoOnly_Passw0rd!
ehr_backup_svc / DemoOnly_B4ckup#
EOF
cat > "$ROOT/it/vpn_config.txt" <<'EOF'
[FAKE] VPN client config - demo content only.
EOF
cat > "$ROOT/it/backup_schedule.txt" <<'EOF'
[FAKE] Nightly backup schedule - demo content only.
EOF
for i in 1 2 3; do
  echo "[FAKE] database backup dump placeholder #$i - see actual seeded DB via psql" > "$ROOT/backups/database_backup_$i.sql"
done
for i in 1 2 3 4 5; do
  echo "[FAKE] internal memo #$i - $COMPANY" > "$ROOT/shared/memo_$i.txt"
done

FILE_COUNT=$(find "$ROOT" -type f | wc -l)
echo "==> Done: $FILE_COUNT files under $ROOT"

# --- Make the engine actually watch $ROOT --------------------------------
WARDEN_CONFIG=/etc/warden/config.toml
if [ ! -f "$WARDEN_CONFIG" ]; then
  echo "!! $WARDEN_CONFIG not found - install PreRan first (sudo ./install.sh), then re-run this script"
  exit 1
fi
if grep -q '^\[ransomware\]' "$WARDEN_CONFIG"; then
  if ! grep -q '^watch_dirs' "$WARDEN_CONFIG"; then
    sudo sed -i "/^\[ransomware\]/a watch_dirs = [\"$ROOT\"]" "$WARDEN_CONFIG"
    echo "==> Added watch_dirs = [\"$ROOT\"] to $WARDEN_CONFIG"
  else
    echo "!! $WARDEN_CONFIG already has a watch_dirs line - make sure it includes \"$ROOT\" yourself"
  fi
else
  printf '\n[ransomware]\nwatch_dirs = ["%s"]\n' "$ROOT" | sudo tee -a "$WARDEN_CONFIG" >/dev/null
  echo "==> Added a new [ransomware] table with watch_dirs = [\"$ROOT\"] to $WARDEN_CONFIG"
fi
echo "==> Restarting warden.service so the new watch_dirs takes effect"
sudo systemctl restart warden.service
sleep 2

# --- Dummy PostgreSQL database (5 tables, ~95 rows) -----------------------
if ! command -v psql >/dev/null 2>&1; then
  echo "==> Installing PostgreSQL..."
  sudo apt-get update -y
  sudo apt-get install -y postgresql postgresql-contrib
fi

sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${DB_USER}') THEN
    CREATE ROLE ${DB_USER} LOGIN PASSWORD '${DB_PASS}';
  END IF;
END
\$\$;

SELECT 'CREATE DATABASE ${DB_NAME} OWNER ${DB_USER}'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DB_NAME}')\gexec
SQL

sudo -u postgres psql -d "$DB_NAME" -v ON_ERROR_STOP=1 <<'SQL'
CREATE TABLE IF NOT EXISTS patients (
  patient_id SERIAL PRIMARY KEY,
  first_name TEXT, last_name TEXT, dob DATE,
  ssn TEXT, diagnosis TEXT, insurance_id TEXT
);
CREATE TABLE IF NOT EXISTS invoices (
  invoice_id TEXT PRIMARY KEY,
  patient_id INT REFERENCES patients(patient_id),
  amount NUMERIC(10,2), card_last4 TEXT, status TEXT
);
CREATE TABLE IF NOT EXISTS staff (
  emp_id TEXT PRIMARY KEY,
  name TEXT, role TEXT, salary NUMERIC(10,2), ssn TEXT
);
CREATE TABLE IF NOT EXISTS lab_results (
  result_id SERIAL PRIMARY KEY,
  patient_id INT REFERENCES patients(patient_id),
  test_name TEXT, result_summary TEXT
);
CREATE TABLE IF NOT EXISTS insurance_claims (
  claim_id TEXT PRIMARY KEY,
  patient_id INT REFERENCES patients(patient_id),
  status TEXT
);

INSERT INTO patients (first_name,last_name,dob,ssn,diagnosis,insurance_id)
SELECT
  (ARRAY['Alicia','Marcus','Priya','Tomas','Sarah','James','Wanjiru','Diego','Fatima','Noah'])[1 + (n % 10)],
  (ARRAY['Nguyen','Ferreira','Chandran','Vukovic','Kim','Ortiz','Karanja','Silva','Haddad','Bennett'])[1 + (n % 10)],
  (DATE '1970-01-01' + (n * 137) * INTERVAL '1 day'),
  '000-' || LPAD((n*7)::text, 2, '0') || '-' || LPAD((n*137+4001)::text, 4, '0'),
  (ARRAY['Hypertension','Type 2 Diabetes','Asthma','Migraine','Hypothyroidism','Anxiety Disorder','Osteoarthritis','GERD'])[1 + (n % 8)],
  'INS-' || (80000 + n)
FROM generate_series(1,30) AS n
ON CONFLICT DO NOTHING;

INSERT INTO invoices (invoice_id,patient_id,amount,card_last4,status)
SELECT 'INV-5' || LPAD(n::text,3,'0'), 1 + (n % 30), (n*37 % 900) + 25, LPAD(((n*111) % 9000 + 1000)::text,4,'0'),
  CASE WHEN n % 3 = 0 THEN 'pending' ELSE 'paid' END
FROM generate_series(1,30) AS n
ON CONFLICT DO NOTHING;

INSERT INTO staff (emp_id,name,role,salary,ssn)
SELECT 'E' || LPAD(n::text,2,'0'),
  (ARRAY['Dr. Sarah Kim','James Ortiz','Wanjiru Karanja','Diego Silva','Fatima Haddad','Noah Bennett','Elena Petrov','Kwame Mensah','Yuki Tanaka','Omar Farouk','Ingrid Larsen','Hassan Ali','Chloe Dubois','Viktor Ivanov','Amara Okafor'])[1 + ((n-1) % 15)],
  (ARRAY['Physician','Nurse Practitioner','Office Manager','Billing Clerk','Lab Technician','IT Administrator','Receptionist','Physical Therapist'])[1 + ((n-1) % 8)],
  55000 + n * 4200,
  '000-' || LPAD((n*11)::text,2,'0') || '-' || LPAD((n*271+2000)::text,4,'0')
FROM generate_series(1,15) AS n
ON CONFLICT DO NOTHING;

INSERT INTO lab_results (patient_id, test_name, result_summary)
SELECT 1 + (n % 30), CASE WHEN n % 2 = 0 THEN 'CBC panel' ELSE 'Lipid panel' END, 'within normal range'
FROM generate_series(1,10) AS n
ON CONFLICT DO NOTHING;

INSERT INTO insurance_claims (claim_id, patient_id, status)
SELECT 'CLM-' || LPAD(n::text,3,'0'), 1 + (n % 30), CASE WHEN n % 2 = 0 THEN 'approved' ELSE 'under review' END
FROM generate_series(1,10) AS n
ON CONFLICT DO NOTHING;
SQL

ROW_COUNT=$(sudo -u postgres psql -d "$DB_NAME" -t -c "
  SELECT (SELECT count(*) FROM patients) + (SELECT count(*) FROM invoices) +
         (SELECT count(*) FROM staff) + (SELECT count(*) FROM lab_results) +
         (SELECT count(*) FROM insurance_claims);" | tr -d '[:space:]')
echo "==> Database '${DB_NAME}' seeded with ${ROW_COUNT} rows across 5 tables. App user: ${DB_USER} / ${DB_PASS}"
echo "    (save this password now — it is not stored anywhere else)"

# --- Register $ROOT with preran-cli's own layer ---------------------------
if command -v preran >/dev/null 2>&1; then
  echo "==> Registering $ROOT as a protected path and enabling protection"
  preran protect enable
  preran protect paths --add "$ROOT"
  preran protect mode enforce

  echo "==> Planting PreRan honeyfiles"
  preran protect honeyfiles create "$ROOT/shared" --count 5
  preran protect honeyfiles create "$ROOT/patient_records" --count 3
  preran protect honeyfiles create "$ROOT/backups" --count 2

  echo "==> Taking an initial baseline sample"
  preran protect boot baseline || true
else
  echo "!! 'preran' CLI not found on PATH - install it first (sudo ./install.sh), then re-run this script"
  exit 1
fi

echo ""
echo "=========================================================================="
echo " Demo environment ready: $FILE_COUNT files, $ROW_COUNT DB rows, under $ROOT"
echo " Engine watching: mode=enforce, burst thresholds from /etc/warden/config.toml"
echo " preran-cli: protection_mode=enforce, preran-watch.service reacting in ~1s"
echo ""
echo " Trigger your ransomware simulator against $ROOT in ANOTHER terminal now."
echo " This terminal is tailing live detection output - Ctrl-C to stop watching"
echo " (does not stop protection)."
echo "=========================================================================="
echo ""
sudo journalctl -u warden.service -u preran-watch.service -f --since now
