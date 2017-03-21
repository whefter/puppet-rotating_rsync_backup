define rotating_rsync_backup::job
(
  $ensure        = present,
  $main_max      = undef,
  $daily_max     = undef,
  $weekly_max    = undef,
  $monthly_max   = undef,
  $sources       = undef,
  $target        = undef,
  $user          = 'root',
  $target_suffix = '',
  $target_host   = undef,
  $target_user   = undef,
  $ssh_identity  = undef,
  $ssh_port      = undef,
  $create_target = false,
  $relative      = false,
  $rsync_params  = undef,
  $cron_minute   = '*',
  $cron_hour     = '*',
  $cron_monthday = '*',
  $cron_month    = '*',
  $cron_weekday  = '*',
  # Deprecated
  $ssh           = undef,
  $target_ident  = undef,
) {
  $configpath_final = join([ $::rotating_rsync_backup::configpath, '/', regsubst($name, '[^a-zA-Z0-9_-]', '_', 'G'), '.conf' ])

  if $ensure == 'present' {
    validate_absolute_path( $::rotating_rsync_backup::configpath )
    validate_re( $ensure, '^(present|absent)$', "Valid values for ensure are 'present' or 'absent'" )
    validate_string( $user )

    if $ssh != undef {
      warning("The 'ssh' parameter has been deprecated and has no function.")
    }

    if $target_ident != undef {
      warning("The 'target_ident' parameter has been deprecated and has no function. Use 'target_suffix' instead.")

      $_target_suffix = $target_ident
    } else {
      $_target_suffix = $target_suffix
    }

    # validate_array( $sources )
    # validate_absolute_path( $target )
    if !is_integer($main_max) { fail('main_max must be an integer') }
    if !is_integer($daily_max) { fail('daily_max must be an integer') }
    if !is_integer($weekly_max) { fail('weekly_max must be an integer') }
    if !is_integer($monthly_max) { fail('monthly_max must be an integer') }

    validate_bool( $relative )

    # if !is_integer($cron_minute) fail('cron_minute must be an integer')
    # if !is_integer($cron_hour) fail('cron_hour must be an integer')
    # if !is_integer($cron_monthday) fail('cron_monthday must be an integer')
    # if !is_integer($cron_month) fail('cron_month must be an integer')
    # if !is_integer($cron_weekday) fail('cron_weekday must be an integer')

    file { $configpath_final:
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('rotating_rsync_backup/config.conf.erb'),
      before  => [
        Cron["rotating_rsync_backup_${name}"],
      ],
    }

    if $create_target {
      if !defined(Exec["Create ${target}/${_target_suffix} and parent directories"]) {
        exec { "Create ${target}/${_target_suffix} and parent directories":
          path    => $::path,
          command => "su - ${user} -c \"mkdir -p --mode 0700 \\\"${target}/${_target_suffix}\\\"\"",
          unless  => "ls \"${target}/${_target_suffix}\"",
        }
      }

      File[$configpath_final] -> Exec["Create ${target}/${_target_suffix} and parent directories"]
      Exec["Create ${target}/${_target_suffix} and parent directories"] -> Cron["rotating_rsync_backup_${name}"]
    }

    cron { "rotating_rsync_backup_${name}":
      ensure   => present,
      command  => "${rotating_rsync_backup::installpath}/rotating-rsync-backup.pl \"${configpath_final}\"",
      hour     => $cron_hour,
      minute   => $cron_minute,
      month    => $cron_month,
      monthday => $cron_monthday,
      weekday  => $cron_weekday,
      user     => $user,
    }
  } elsif $ensure == 'absent' {
    cron { "rotating_rsync_backup_${name}":
      ensure => absent,
      user   => $user,
    }
    ->
    file { $configpath_final:
      ensure => absent,
    }
  }
}
