# 🖥️ sshmx - Manage Your SSH Connections Easily

[![Download sshmx](https://img.shields.io/badge/Download-sshmx-blue)](https://github.com/ajaysharma1258/sshmx/releases)

## 🚀 Getting Started

SSH Manager (sshmx) is a lightweight command-line tool. It helps you organize and manage multiple SSH connections effortlessly. You can save host configurations, set aliases, and connect quickly, all without the hassle of editing your .ssh/config file. This tool is perfect for developers, system administrators, and DevOps teams who prioritize efficiency in the terminal.

## 📥 Download & Install

To download sshmx, visit the following link:

[Download sshmx from Releases](https://github.com/ajaysharma1258/sshmx/releases)

Once you are on the releases page, find the latest version of sshmx. You will see a list of downloadable files. Choose the appropriate file for your operating system and download it.

## ⚙️ System Requirements

Before you begin, make sure you have the following:

- Operating System: Linux, macOS, or Windows
- Terminal application (most modern systems have this by default)

Having a basic understanding of how to use a terminal will help you navigate the setup.

## 💾 How to Install

Follow these steps to install sshmx:

1. **Download** the appropriate file from the releases page.
2. Extract the downloaded file if it is in a compressed format (zip, tar, etc.).
3. Move the extracted file to a directory in your system PATH. This allows you to run sshmx from any terminal.

   - For example, on Linux or macOS, you can use:
     ```
     mv sshmx /usr/local/bin/
     ```

   - On Windows, you might consider placing it in:
     ```
     C:\Program Files\sshmx\
     ```

4. **Set Permissions** if you are using Linux or macOS:
   ```
   chmod +x /usr/local/bin/sshmx
   ```

## ⚙️ Using sshmx

### Basic Commands

Here are some basic commands to get you started:

1. **Add SSH Host:**
   To add a new SSH host, use:
   ```
   sshmx add [alias] [hostname]
   ```

   Example:
   ```
   sshmx add myserver 192.168.1.1
   ```

2. **List SSH Hosts:**
   To see all your saved SSH hosts, run:
   ```
   sshmx list
   ```

3. **Connect to an SSH Host:**
   To connect to a saved SSH host, use:
   ```
   sshmx connect [alias]
   ```

   Example:
   ```
   sshmx connect myserver
   ```

### Saving Configurations

You can save configurations for each host:

- Specify a port:
  ```
  sshmx add [alias] [hostname] --port [port_number]
  ```

- Set a custom user:
  ```
  sshmx add [alias] [hostname] --user [username]
  ```

### Removing Hosts

To remove a saved SSH host, use:
```
sshmx remove [alias]
```

Example:
```
sshmx remove myserver
```

## 🛠️ Troubleshooting

- **Command Not Found:** If you see a "command not found" error, ensure that the sshmx file is in your system PATH.
- **Permission Denied:** If you cannot run sshmx, check if you followed the step to set permissions correctly on Linux or macOS.
- **Connection Issues:** Verify that your network is working and that the hostname and port are correct.

## 👥 Community Support

If you encounter any issues or need help, you can visit our [GitHub Discussions](https://github.com/ajaysharma1258/sshmx/discussions) page to ask questions or share tips. The community is here to help you.

## 📝 License

This project is licensed under the MIT License. You can freely use and modify it for your own needs.

Feel free to reach out or contribute through the GitHub repository. Your feedback is welcome as we continuously improve sshmx to suit your needs better.

[Download sshmx from Releases](https://github.com/ajaysharma1258/sshmx/releases) and take control of your SSH connections today!