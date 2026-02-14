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

if [[ ! "${prd_file}" =~ ^PRD-([0-9]+)_(.+)\.md$ ]]; then
  echo "Invalid PRD filename format: ${prd_file}"
  echo "Expected: PRD-<N>_<action>.md"
  exit 1
fi

prd_no="${BASH_REMATCH[1]}"
action="${BASH_REMATCH[2]}"

src_prd="${factory_project_root}/docs/prd/PRD-${prd_no}_${action}.md"
src_b="${factory_project_root}/docs/contract/specs/B-${prd_no}_${action}.contract.md"
src_c="${factory_project_root}/docs/contract/intent_maps/C-${prd_no}_${action}.intent_map.md"
src_d="${factory_project_root}/docs/platform/D-${prd_no}_${action}.platform.md"

dst_prd="${main_project_root}/docs/prd/PRD-${prd_no}_${action}.md"
dst_b="${main_project_root}/docs/contract/specs/B-${prd_no}_${action}.contract.md"
dst_c="${main_project_root}/docs/contract/intent_maps/C-${prd_no}_${action}.intent_map.md"
dst_d="${main_project_root}/docs/platform/D-${prd_no}_${action}.platform.md"

archive_prd="${factory_project_root}/_imported/docs/prd/PRD-${prd_no}_${action}.md"
archive_b="${factory_project_root}/_imported/docs/contract/specs/B-${prd_no}_${action}.contract.md"
archive_c="${factory_project_root}/_imported/docs/contract/intent_maps/C-${prd_no}_${action}.intent_map.md"
archive_d="${factory_project_root}/_imported/docs/platform/D-${prd_no}_${action}.platform.md"

missing_sources=()
for src in "${src_prd}" "${src_b}" "${src_c}" "${src_d}"; do
  if [[ ! -f "${src}" ]]; then
    missing_sources+=("${src}")
  fi
done

if [[ ${#missing_sources[@]} -gt 0 ]]; then
  echo
  echo "Abort: missing source files:"
  print_list missing_sources
  exit 1
fi

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
echo "PRD: PRD-${prd_no}_${action}.md"
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
echo "  git commit -m \"docs: import PRD-${prd_no} ${action} ABCD\""
echo
echo "Self-check:"
echo "  1) Re-run importer and confirm PRD-${prd_no}_${action}.md is not listed."
echo "  2) Verify imported files exist under ${main_project_root}/docs/."
