def test_file_exists(host):
    docker_app = host.file('/docker_app.yml')
    assert docker_app.exists
    assert docker_app.contains('your')

# def test_docker_app_is_installed(host):
#     docker_app = host.package('docker_app')
#     assert docker_app.is_installed
#
#
# def test_user_and_group_exist(host):
#     user = host.user('docker_app')
#     assert user.group == 'docker_app'
#     assert user.home == '/var/lib/docker_app'
#
#
# def test_service_is_running_and_enabled(host):
#     docker_app = host.service('docker_app')
#     assert docker_app.is_enabled
#     assert docker_app.is_running
