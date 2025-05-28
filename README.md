![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat&logo=powershell&logoColor=white)
![Windows 11](https://img.shields.io/badge/Windows%2011-0078D4?style=flat&logo=windows&logoColor=white)
![Hosts File](https://img.shields.io/badge/Hosts%20File-✓-purple)
![Backup](https://img.shields.io/badge/Backup-✓-orange)
![IPv4](https://img.shields.io/badge/IPv4-✓-yellowgreen)
![IPv6](https://img.shields.io/badge/IPv6-✓-lightblue)
![Logging](https://img.shields.io/badge/Logging-✓-blue)
![Duplicate Check](https://img.shields.io/badge/Duplicate%20Check-✓-green)
![Export/Import](https://img.shields.io/badge/Export%2FImport-✓-pink)

# Hosts File Manager for Windows 11

A PowerShell script for managing the Windows hosts file. This script is adapted from a macOS zsh version and provides a robust set of features for editing, validating, and backing up the hosts file.

---

## Features

- **Automatic Backup:** Creates and rotates backups of the hosts file.
- **Restore:** Restores the hosts file from a selected backup.
- **Add/Remove Entries:** Easily add or remove host entries by IP or hostname.
- **Validation:** Validates hosts file syntax for both IPv4 and IPv6 addresses.
- **Duplicate Check:** Detects and displays duplicate IP-hostname pairs.
- **Export/Import:** Export the current hosts file or import from a file.
- **Reset:** Resets the hosts file to the default Windows configuration.
- **Logging:** Timestamped logging of all actions.
- **Admin Check:** Ensures the script is run with administrator privileges.
- **Clear Menu Interface:** Simple and intuitive menu-driven interface.

---

## Usage

1. **Run as Administrator:**  
   Right-click the PowerShell icon, select "Run as administrator," then navigate to the script location.
2. **Execute the Script:**  
   Run the script:  
```
.\hosts_manager.ps1
```
3. **Follow the Menu:**  
   Use the menu to select the desired action (add, remove, backup, restore, etc.).

---

## Requirements

- **Windows 11** (also works on Windows 10 with PowerShell 5.1+)
- **PowerShell 5.1 or later**

---

## Example
```
Select an action:
	1.	Reset to default
	2.	Restore from backup
	3.	Show current content
	4.	Create a backup
	5.	Add host entry
	6.	Remove host entry
	7.	Validate hosts file syntax
	8.	Check for duplicate IP-hostname pairs
	9.	Export hosts to file
	10.	Import hosts from file
	11.	Exit
Your choice: 5 Enter IP address: 192.168.1.100 Enter hostname: example.local Added entry: 192.168.1.100 example.local
```

---

## Notes

- **Backup Location:** Backups are saved in `C:\Windows\System32\drivers\etc` as `hosts.backup.<timestamp>`.
- **Logging:** Logs are written to `%USERPROFILE%\hosts_manager.log`.
- **Administrator Rights:** The script must be run as administrator to modify the hosts file.
- **Export/Import:** If only a filename is provided, the file is saved in the current directory.

---

## License

MIT License

---

## Contact

For questions or suggestions, please open an issue in the repository or contact the author.

---

**Enjoy managing your hosts file with ease!**
