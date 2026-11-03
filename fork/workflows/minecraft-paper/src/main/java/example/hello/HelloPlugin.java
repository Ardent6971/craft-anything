package example.hello;

import org.bukkit.command.Command;
import org.bukkit.command.CommandSender;
import org.bukkit.plugin.java.JavaPlugin;

/** A starter plugin: one command, one log line. Replace with the requested feature. */
public final class HelloPlugin extends JavaPlugin {
    @Override
    public void onEnable() {
        getLogger().info("HelloPlugin enabled");
    }

    @Override
    public boolean onCommand(CommandSender sender, Command command, String label, String[] args) {
        if (!command.getName().equalsIgnoreCase("hello")) {
            return false;
        }
        sender.sendMessage("Hello, " + sender.getName() + "!");
        return true;
    }
}
