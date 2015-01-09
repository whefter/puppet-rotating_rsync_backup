class rotating_rsync_backup (
    $ensure                 = 'present',
    
    $source_repo            = 'https://github.com/whefter/rotating-rsync-backup.git',
    $source_branch          = undef,
    $source_ensure          = 'present',
    
    $installpath            = '/usr/share/rotating-rsync-backup',
    $configpath             = '/etc/rotating-rsync-backup',
    $jobs                   = {},
) {
    $config_path_ensure = $ensure ? {
        /(present|installed)/       => 'directory',
        default                     => 'absent',
    }
    
    class { 'rotating_rsync_backup::install':}
    ->
    file { $configpath:
        ensure     => $config_path_ensure,
        owner      => 'root',
        group      => 'root',
        mode       => '0644',
    }

    create_resources( rotating_rsync_backup::job, $jobs )
}
