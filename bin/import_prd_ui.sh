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

if [[ ! -f "${src_prd}" ]]; then
  echo "Abort: Missing PRD-${prd_num} file"
  exit 1
fi

if [[ -z "${src_b}" ]]; then
  echo "WARN: Missing B-${prd_num} (optional) - will skip copy/archive"
fi
if [[ -z "${src_c}" ]]; then
  echo "WARN: Missing C-${prd_num} (optional) - will skip copy/archive"
fi
if [[ -z "${src_d}" ]]; then
  echo "WARN: Missing D-${prd_num} (optional) - will skip copy/archive"
fi

prd_name="$(basename "${src_prd}")"
b_name=""
c_name=""
d_name=""
[[ -n "${src_b}" ]] && b_name="$(basename "${src_b}")"
[[ -n "${src_c}" ]] && c_name="$(basename "${src_c}")"
[[ -n "${src_d}" ]] && d_name="$(basename "${src_d}")"

dst_prd="${main_project_root}/docs/prd/${prd_name}"
dst_b=""
dst_c=""
dst_d=""
[[ -n "${b_name}" ]] && dst_b="${main_project_root}/docs/contract/specs/${b_name}"
[[ -n "${c_name}" ]] && dst_c="${main_project_root}/docs/contract/intent_maps/${c_name}"
[[ -n "${d_name}" ]] && dst_d="${main_project_root}/docs/platform/${d_name}"

archive_prd="${factory_project_root}/_imported/docs/prd/${prd_name}"
archive_b=""
archive_c=""
archive_d=""
[[ -n "${b_name}" ]] && archive_b="${factory_project_root}/_imported/docs/contract/specs/${b_name}"
[[ -n "${c_name}" ]] && archive_c="${factory_project_root}/_imported/docs/contract/intent_maps/${c_name}"
[[ -n "${d_name}" ]] && archive_d="${factory_project_root}/_imported/docs/platform/${d_name}"

copy_targets=("${dst_prd}")
archive_targets=("${archive_prd}")
[[ -n "${dst_b}" ]] && copy_targets+=("${dst_b}")
[[ -n "${dst_c}" ]] && copy_targets+=("${dst_c}")
[[ -n "${dst_d}" ]] && copy_targets+=("${dst_d}")
[[ -n "${archive_b}" ]] && archive_targets+=("${archive_b}")
[[ -n "${archive_c}" ]] && archive_targets+=("${archive_c}")
[[ -n "${archive_d}" ]] && archive_targets+=("${archive_d}")

existing_destinations=()
for dst in "${copy_targets[@]}"; do
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
for arc in "${archive_targets[@]}"; do
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

copy_dirs=("$(dirname "${dst_prd}")")
[[ -n "${dst_b}" ]] && copy_dirs+=("$(dirname "${dst_b}")")
[[ -n "${dst_c}" ]] && copy_dirs+=("$(dirname "${dst_c}")")
[[ -n "${dst_d}" ]] && copy_dirs+=("$(dirname "${dst_d}")")
mkdir -p "${copy_dirs[@]}"

cp "${src_prd}" "${dst_prd}"
[[ -n "${src_b}" ]] && cp "${src_b}" "${dst_b}"
[[ -n "${src_c}" ]] && cp "${src_c}" "${dst_c}"
[[ -n "${src_d}" ]] && cp "${src_d}" "${dst_d}"

for required_dst in "${copy_targets[@]}"; do
  if [[ ! -f "${required_dst}" ]]; then
    echo "Abort: copy verification failed for ${required_dst}"
    exit 1
  fi
done

archive_dirs=("${factory_project_root}/_imported/docs/prd")
[[ -n "${archive_b}" ]] && archive_dirs+=("${factory_project_root}/_imported/docs/contract/specs")
[[ -n "${archive_c}" ]] && archive_dirs+=("${factory_project_root}/_imported/docs/contract/intent_maps")
[[ -n "${archive_d}" ]] && archive_dirs+=("${factory_project_root}/_imported/docs/platform")
mkdir -p "${archive_dirs[@]}"

mv "${src_prd}" "${archive_prd}"
[[ -n "${src_b}" ]] && mv "${src_b}" "${archive_b}"
[[ -n "${src_c}" ]] && mv "${src_c}" "${archive_c}"
[[ -n "${src_d}" ]] && mv "${src_d}" "${archive_d}"

echo
echo "Import completed successfully."
echo "Project: ${project}"
echo "PRD: ${prd_name}"
echo "Copied into main repo:"
echo "  - ${dst_prd}"
if [[ -n "${dst_b}" ]]; then
  echo "  - ${dst_b}"
else
  echo "  - (skipped) B-${prd_num}"
fi
if [[ -n "${dst_c}" ]]; then
  echo "  - ${dst_c}"
else
  echo "  - (skipped) C-${prd_num}"
fi
if [[ -n "${dst_d}" ]]; then
  echo "  - ${dst_d}"
else
  echo "  - (skipped) D-${prd_num}"
fi
echo "Archived in docs-factory:"
echo "  - ${archive_prd}"
if [[ -n "${archive_b}" ]]; then
  echo "  - ${archive_b}"
else
  echo "  - (skipped) B-${prd_num}"
fi
if [[ -n "${archive_c}" ]]; then
  echo "  - ${archive_c}"
else
  echo "  - (skipped) C-${prd_num}"
fi
if [[ -n "${archive_d}" ]]; then
  echo "  - ${archive_d}"
else
  echo "  - (skipped) D-${prd_num}"
fi
echo
echo "Next steps:"
echo "  cd \"${main_project_root}\""
echo "  git add docs/"
echo "  git commit -m \"docs: import PRD-${prd_num} ABCD\""
echo
echo "Self-check:"
echo "  1) Re-run importer and confirm ${prd_name} is not listed."
echo "  2) Verify imported files exist under ${main_project_root}/docs/."
