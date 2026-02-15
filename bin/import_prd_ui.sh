#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FACTORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MAIN_ROOT="${MAIN_REPOS_ROOT:-/home/sung2287/projects}"

print_list() {
  local -n _items=$1
  for item in "${_items[@]}"; do
    echo "  - ${item}"
  done
}

select_from_list() {
  local out_var="$1"
  shift
  local prompt="$1"
  shift
  local options=("$@")
  local selected=""
  PS3="${prompt} "
  select opt in "${options[@]}" "Quit"; do
    if [[ "${opt:-}" == "Quit" ]]; then
      echo "Cancelled."
      exit 0
    fi
    if [[ -n "${opt:-}" ]]; then
      selected="${opt}"
      break
    fi
    echo "Invalid selection. Try again."
  done
  printf -v "${out_var}" '%s' "${selected}"
}

pick_first_by_prefix() {
  local dir="$1"
  local prefix="$2"
  local suffix="$3"
  local path=""
  local name=""
  local rest=""

  while IFS= read -r path; do
    name="$(basename "${path}")"
    rest="${name#${prefix}}"
    if [[ "${rest}" == "${name}" || -z "${rest}" ]]; then
      continue
    fi
    if [[ "${rest}" =~ ^[0-9] ]]; then
      continue
    fi
    echo "${path}"
    return 0
  done < <(find "${dir}" -mindepth 1 -maxdepth 1 -type f -name "${prefix}*${suffix}" | sort)

  return 1
}

echo "== PRD Importer (WSL) =="
echo "Factory root: ${FACTORY_ROOT}"

mapfile -t project_dirs < <(
  find "${FACTORY_ROOT}" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' \
    ! -name 'bin' \
    ! -name 'launcher' \
    | sort
)

projects=()
for dir in "${project_dirs[@]}"; do
  if [[ -d "${dir}/docs/prd" ]]; then
    projects+=("$(basename "${dir}")")
  fi
done

if [[ ${#projects[@]} -eq 0 ]]; then
  echo "No projects found. Expected: <factory>/<project>/docs/prd"
  exit 1
fi

echo
echo "Select project:"
select_from_list project "Project number?" "${projects[@]}"
factory_project_root="${FACTORY_ROOT}/${project}"
main_project_root="${MAIN_ROOT}/${project}"

if [[ ! -d "${main_project_root}" ]]; then
  echo "Main repo not found: ${main_project_root}"
  exit 1
fi

mapfile -t prd_candidates < <(
  find "${factory_project_root}/docs/prd" -mindepth 1 -maxdepth 1 -type f -name 'PRD-*.md' -printf '%f\n' \
    | sort -V
)

if [[ ${#prd_candidates[@]} -eq 0 ]]; then
  echo "No PRD candidates found in ${factory_project_root}/docs/prd"
  echo "Imported PRDs are expected to live under ${factory_project_root}/_imported/docs/"
  exit 0
fi

echo
echo "Select PRD:"
select_from_list prd_file "PRD number?" "${prd_candidates[@]}"

if [[ ! "${prd_file}" =~ ^PRD-[0-9]+_.+\.md$ ]]; then
  echo "Invalid PRD filename format: ${prd_file}"
  echo "Expected: PRD-<N>_<action>.md"
  exit 1
fi

prd_num="${prd_file#PRD-}"
prd_num="${prd_num%%_*}"

if [[ ! "${prd_num}" =~ ^[0-9]+$ ]]; then
  echo "Invalid PRD number: ${prd_num}"
  exit 1
fi

src_prd="${factory_project_root}/docs/prd/${prd_file}"

src_b="$(pick_first_by_prefix "${factory_project_root}/docs/contract/specs" "B-${prd_num}" ".contract.md" || true)"
src_c="$(pick_first_by_prefix "${factory_project_root}/docs/contract/intent_maps" "C-${prd_num}" ".intent_map.md" || true)"
src_d="$(pick_first_by_prefix "${factory_project_root}/docs/platform" "D-${prd_num}" ".platform.md" || true)"

missing_sources=()
if [[ ! -f "${src_prd}" ]]; then
  missing_sources+=("Missing PRD-${prd_num} file")
fi
if [[ -z "${src_b}" ]]; then
  missing_sources+=("Missing B-${prd_num} file")
fi
if [[ -z "${src_c}" ]]; then
  missing_sources+=("Missing C-${prd_num} file")
fi
if [[ -z "${src_d}" ]]; then
  missing_sources+=("Missing D-${prd_num} file")
fi

if [[ ${#missing_sources[@]} -gt 0 ]]; then
  echo
  echo "Abort:"
  for msg in "${missing_sources[@]}"; do
    echo "${msg}"
  done
  exit 1
fi

prd_name="$(basename "${src_prd}")"
b_name="$(basename "${src_b}")"
c_name="$(basename "${src_c}")"
d_name="$(basename "${src_d}")"

dst_prd="${main_project_root}/docs/prd/${prd_name}"
dst_b="${main_project_root}/docs/contract/specs/${b_name}"
dst_c="${main_project_root}/docs/contract/intent_maps/${c_name}"
dst_d="${main_project_root}/docs/platform/${d_name}"

archive_prd="${factory_project_root}/_imported/docs/prd/${prd_name}"
archive_b="${factory_project_root}/_imported/docs/contract/specs/${b_name}"
archive_c="${factory_project_root}/_imported/docs/contract/intent_maps/${c_name}"
archive_d="${factory_project_root}/_imported/docs/platform/${d_name}"

existing_destinations=()
for dst in "${dst_prd}" "${dst_b}" "${dst_c}" "${dst_d}"; do
  if [[ -e "${dst}" ]]; then
    existing_destinations+=("${dst}")
  fi
done

if [[ ${#existing_destinations[@]} -gt 0 ]]; then
  echo
  echo "Abort: destination already exists (no overwrite):"
  print_list existing_destinations
  exit 1
fi

existing_archives=()
for arc in "${archive_prd}" "${archive_b}" "${archive_c}" "${archive_d}"; do
  if [[ -e "${arc}" ]]; then
    existing_archives+=("${arc}")
  fi
done

if [[ ${#existing_archives[@]} -gt 0 ]]; then
  echo
  echo "Abort: archive target already exists:"
  print_list existing_archives
  exit 1
fi

mkdir -p "$(dirname "${dst_prd}")" "$(dirname "${dst_b}")" "$(dirname "${dst_c}")" "$(dirname "${dst_d}")"

cp "${src_prd}" "${dst_prd}"
cp "${src_b}" "${dst_b}"
cp "${src_c}" "${dst_c}"
cp "${src_d}" "${dst_d}"

for required_dst in "${dst_prd}" "${dst_b}" "${dst_c}" "${dst_d}"; do
  if [[ ! -f "${required_dst}" ]]; then
    echo "Abort: copy verification failed for ${required_dst}"
    exit 1
  fi
done

mkdir -p \
  "${factory_project_root}/_imported/docs/prd" \
  "${factory_project_root}/_imported/docs/contract/specs" \
  "${factory_project_root}/_imported/docs/contract/intent_maps" \
  "${factory_project_root}/_imported/docs/platform"

mv "${src_prd}" "${archive_prd}"
mv "${src_b}" "${archive_b}"
mv "${src_c}" "${archive_c}"
mv "${src_d}" "${archive_d}"

echo
echo "Import completed successfully."
echo "Project: ${project}"
echo "PRD: ${prd_name}"
echo "Copied into main repo:"
echo "  - ${dst_prd}"
echo "  - ${dst_b}"
echo "  - ${dst_c}"
echo "  - ${dst_d}"
echo "Archived in docs-factory:"
echo "  - ${archive_prd}"
echo "  - ${archive_b}"
echo "  - ${archive_c}"
echo "  - ${archive_d}"
echo
echo "Next steps:"
echo "  cd \"${main_project_root}\""
echo "  git add docs/"
echo "  git commit -m \"docs: import PRD-${prd_num} ABCD\""
echo
echo "Self-check:"
echo "  1) Re-run importer and confirm ${prd_name} is not listed."
echo "  2) Verify imported files exist under ${main_project_root}/docs/."
