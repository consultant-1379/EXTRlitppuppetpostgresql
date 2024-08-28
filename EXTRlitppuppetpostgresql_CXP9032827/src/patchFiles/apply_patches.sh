#!/bin/bash
# Apply sed commands and file re-naming to the puppet postgres module
# Takes the puppet postgres module top level directory as input.
mv='/bin/mv'
find='/bin/find'
echo='/bin/echo'
sed='/bin/sed'
set -x

function exit_on_error {
  local msg=$1
  ${echo} "ERROR: ${msg}" && exit 1
}

patch_dir=$1

[ -z "${patch_dir}" ] && exit_on_error "The puppet postgres module top level directory is required as input"

type_dir="${patch_dir}/lib/puppet/type"
provider_dir="${patch_dir}/lib/puppet/provider"
postgresql_psql_type="${type_dir}/postgresql_psql.rb"
postgresql_litp_psql_type="${type_dir}/postgresql_litp_psql.rb"
postgresql_conf_type="${type_dir}/postgresql_conf.rb"
postgresql_litp_conf_type="${type_dir}/postgresql_litp_conf.rb"
postgresql_psql_provider_dir="${provider_dir}/postgresql_psql"
postgresql_litp_psql_provider_dir="${provider_dir}/postgresql_litp_psql"
postgresql_conf_provider_dir="${provider_dir}/postgresql_conf"
postgresql_litp_conf_provider_dir="${provider_dir}/postgresql_litp_conf"

for pair in ${postgresql_psql_type},${postgresql_litp_psql_type} \
${postgresql_conf_type},${postgresql_litp_conf_type} \
${postgresql_psql_provider_dir},${postgresql_litp_psql_provider_dir} \
${postgresql_conf_provider_dir},${postgresql_litp_conf_provider_dir};
do
  IFS=','
  set -- $pair
  "${mv}" "${1}" "${2}" || exit_on_error "Failed to move $1 to $2"
done

"${find}" "${patch_dir}" -type f | xargs "${sed}" -i -E \
-e 's#(puppet:///modules/postgresql)/#\1_litp/#g' \
-e "s#(template\('postgresql)#\1_litp#g" \
-e 's/(postgresql)::/\1_litp::/gi' \
-e 's/(\<postgresql)_(psql)\>/\1_litp_\2/gi' \
-e 's/(\<postgresql)_(conf)\>/\1_litp_\2/gi' \
|| exit_on_error "Sed commands to update puppet postgres module failed"
