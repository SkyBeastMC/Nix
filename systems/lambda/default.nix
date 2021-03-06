{ config, lib, pkgs, ... }:

with lib;

let
	protonvpn = if (builtins.tryEval <protonvpn>).success then <protonvpn> else fetchGit {
		url = "git@github.com:LightDiscord/ProtonVPN-Nix";
		rev = "a9ebf5fd59657d954da9e6a596913ab0d0beb2a0";
	};
in {
	imports = [
		(import protonvpn)

		<nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>

		../../users/arnaud
		../../users/arnaud/home-manager.nix
	];

	sound.enable = true;
	sound.mediaKeys.enable = config.sound.enable;

	users.mutableUsers = false;

	system.stateVersion = mkForce "19.03";

	time.timeZone = "Europe/Paris";

	fonts = {
		fontconfig.enable = true;

		fonts = with pkgs; [
			fira-code
			emojione
		];
	};

	services.tor = {
		enable = true;
		client.enable = true;
	};

	i18n.defaultLocale = "en_US.UTF-8";

	services.openssh.enable = true;

	networking = {
		networkmanager.enable = true;
		hostName = "Lambda";
	};

	environment.systemPackages = with pkgs; [
		neovim tmux kitty

		# Yubikey
		opensc gnupg pcsctools yubikey-personalization
	];

	nixpkgs.config.allowUnfree = true;

	services.openvpn.providers.protonvpn = {
		enable = true;
		country = "fr";
		credentials = /etc/keys/protonvpn.txt;
	};

	# Yubikey part
	services.pcscd.enable = true;

	services.udev.packages = with pkgs; [
		yubikey-personalization
	];

	programs.ssh.startAgent = false;

	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	services.gnome3.gnome-keyring.enable = true;

	security.pam.services.lightdm.enableGnomeKeyring =
		config.services.xserver.displayManager.lightdm.enable;

	# xserver configuration.
	services.xserver = {
		enable = true;

		displayManager.lightdm = {
			inherit (config.services.xserver) enable;

			background = toString (pkgs.fetchurl {
				url = https://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-656580.png;
				sha256 = "0pqxwsgyjvs7pnqnqlm3d7vw21xikw4j046l82gj6mlpg3w4fdrn";
			});
		};
	};

	hardware.sane = {
		enable = true;

		brscan4.enable = config.hardware.sane.enable;
	};

	boot = {
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
		cleanTmpDir = true;
		kernelPackages = pkgs.linuxPackages_latest;
		initrd.availableKernelModules = [
			"xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod"
		];
		kernelModules = ["kvm-intel"];
		extraModulePackages = [];
	};

	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
		tcp = {
			enable = true;
			anonymousClients.allowedIpRanges = ["127.0.0.1"];
		};
	};
}
