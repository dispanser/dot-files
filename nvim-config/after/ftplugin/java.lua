local config = {
  root_dir = vim.fs.dirname(
		vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
	cmd = {
		'/nix/store/l49ka91sll5r46xk5fmmxgp6pgz6xlh9-zulu19.30.11-ca-jdk-19.0.1/bin/java',
		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Xms1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens', 'java.base/java.util=ALL-UNNAMED',
		'--add-opens', 'java.base/java.lang=ALL-UNNAMED',
		'-jar', '/Users/pi/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
		'-configuration', '/Users/pi/.local/share/nvim/mason/packages/jdtls/config_mac',
		'-data', '/Users/pi/dremio/jdtls-workspace'
	},
}
print("twh; java.lua")
require('jdtls').start_or_attach(config)
