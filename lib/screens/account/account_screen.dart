import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/api.service.dart'; // Pinalitan ang _ ng .
import '../../theme/app.theme.dart';     // Pinalitan ang _ ng .

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getCurrentUser();
    setState(() { _user = user; _loading = false; });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _editProfile() async {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!.name);
    final addressCtrl = TextEditingController(text: _user!.address);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateProfile(name: nameCtrl.text, address: addressCtrl.text);
              Navigator.pop(ctx);
              _loadUser();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {})],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _user?.name.substring(0, 1).toUpperCase() ?? 'G',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_user?.name ?? 'Guest',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                              Text(_user?.phone ?? 'Not logged in',
                                  style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                              TextButton(
                                onPressed: _user != null ? _editProfile : null,
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                child: const Text('Edit Profile', style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(icon: Icons.location_on_outlined, label: 'My Addresses', onTap: () {}),
                  _MenuItem(icon: Icons.credit_card_outlined, label: 'Payment Methods', onTap: () {}),
                  _MenuItem(icon: Icons.receipt_long_outlined, label: 'Order History',
                      onTap: () => Navigator.pushNamed(context, '/my-orders')),
                  _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  _MenuItem(icon: Icons.help_outline, label: 'Help Center', onTap: () {}),
                  _MenuItem(icon: Icons.info_outline, label: 'About Us', onTap: () {}),
                  const SizedBox(height: 8),
                  if (_user != null)
                    _MenuItem(icon: Icons.logout, label: 'Logout', color: AppColors.danger, onTap: _logout),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.textDark),
        title: Text(label, style: TextStyle(color: color ?? AppColors.textDark)),
        trailing: color == null ? Icon(Icons.chevron_right, color: AppColors.textLight) : null, // Inalis ang const dito
        onTap: onTap,
      ),
    );
  }
}
