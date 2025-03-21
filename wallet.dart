import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WalletScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const WalletScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  double _balance = 9900000.00;
  List<Map<String, dynamic>> _cards = [];
  List<Map<String, dynamic>> _transactions = [];
  List<int> _selectedTransactionIndices = [];
  bool _isSelecting = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cardsJson = prefs.getString('cards');
    final String? transactionsJson = prefs.getString('transactions');
    final double? savedBalance = prefs.getDouble('balance');

    setState(() {
      _cards =
          _parseJsonList(cardsJson) ??
          [
            {
              'number': '**** **** **** 1234',
              'name': 'John Doe',
              'type': 'Visa',
              'isDefault': true,
            },
            {
              'number': '**** **** **** 5678',
              'name': 'Jane Doe',
              'type': 'MasterCard',
              'isDefault': false,
            },
          ];
      _transactions =
          _parseJsonList(transactionsJson) ??
          [
            {
              'type': 'Food Order',
              'amount': -350.00,
              'date': DateTime.now().toString(),
            },
            {
              'type': 'Added Funds',
              'amount': 1000.00,
              'date': DateTime.now().toString(),
            },
          ];
      _balance = savedBalance ?? 9900000.00;
    });
    await _saveData();
  }

  List<Map<String, dynamic>>? _parseJsonList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cards', jsonEncode(_cards));
    await prefs.setString('transactions', jsonEncode(_transactions));
    await prefs.setDouble('balance', _balance);
  }

  void _addCard() {
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Add New Card',
            [
              TextField(
                controller: _cardNumberController,
                decoration: _textFieldDecoration('Card Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardNameController,
                decoration: _textFieldDecoration('Cardholder Name'),
              ),
            ],
            () {
              if (_cardNumberController.text.isNotEmpty &&
                  _cardNameController.text.isNotEmpty) {
                setState(() {
                  _cards.add({
                    'number': _cardNumberController.text,
                    'name': _cardNameController.text,
                    'type': _cards.length % 2 == 0 ? 'Visa' : 'MasterCard',
                    'isDefault': false,
                  });
                });
                _saveData();
                Navigator.pop(context);
                _showSuccessAnimation('Card Added Successfully');
                _cardNumberController.clear();
                _cardNameController.clear();
              }
            },
          ),
    );
  }

  void _deleteCard(int index) {
    setState(() {
      _cards.removeAt(index);
    });
    _saveData();
  }

  void _setDefaultCard(int index) {
    setState(() {
      for (int i = 0; i < _cards.length; i++) {
        _cards[i]['isDefault'] = (i == index);
      }
    });
    _saveData();
  }

  void _showCardOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder:
          (context) => _buildBottomSheet([
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                _deleteCard(index);
                Navigator.pop(context);
              },
            ),
          ]),
    );
  }

  void _performTransaction(
    String type,
    double amount, {
    Map<String, String>? details,
  }) {
    setState(() {
      _balance += amount;
      _transactions.insert(0, {
        'type': type,
        'amount': amount,
        'date': DateTime.now().toString(),
        ...?details,
      });
    });
    _saveData();
  }

  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
    _saveData();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedTransactionIndices.contains(index)) {
        _selectedTransactionIndices.remove(index);
      } else {
        _selectedTransactionIndices.add(index);
      }
      _isSelecting = _selectedTransactionIndices.isNotEmpty;
    });
  }

  void _deleteSelectedTransactions() {
    setState(() {
      // Create a new list excluding the selected indices
      _transactions =
          _transactions
              .asMap()
              .entries
              .where(
                (entry) => !_selectedTransactionIndices.contains(entry.key),
              )
              .map((entry) => entry.value)
              .toList();
      _selectedTransactionIndices.clear();
      _isSelecting = false;
    });
    _saveData();
  }

  void _deposit() {
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Deposit Funds',
            [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _textFieldDecoration('Amount'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sourceController,
                decoration: _textFieldDecoration('Source (e.g., Bank Name)'),
              ),
            ],
            () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _performTransaction(
                  'Deposited Funds',
                  amount,
                  details: {'source': _sourceController.text},
                );
                _showSuccessAnimation('Deposited Successfully');
                _amountController.clear();
                _sourceController.clear();
              }
            },
          ),
    );
  }

  void _withdraw() {
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Withdraw Funds',
            [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _textFieldDecoration('Amount'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _destinationController,
                decoration: _textFieldDecoration(
                  'Destination (e.g., Bank Account)',
                ),
              ),
            ],
            () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0 && amount <= _balance) {
                Navigator.pop(context);
                _performTransaction(
                  'Withdrawn Funds',
                  -amount,
                  details: {'destination': _destinationController.text},
                );
                _showSuccessAnimation('Withdrawn Successfully');
                _amountController.clear();
                _destinationController.clear();
              }
            },
          ),
    );
  }

  void _mobileTopUp() {
    String? selectedProvider;
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Mobile Top-Up',
            [
              DropdownButtonFormField<String>(
                decoration: _textFieldDecoration('Select Provider'),
                items:
                    ['Jazz', 'Zong', 'Telenor', 'Ufone']
                        .map(
                          (provider) => DropdownMenuItem(
                            value: provider,
                            child: Text(provider),
                          ),
                        )
                        .toList(),
                onChanged: (value) => selectedProvider = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: _textFieldDecoration('Phone Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _textFieldDecoration('Amount'),
              ),
            ],
            () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null &&
                  amount > 0 &&
                  amount <= _balance &&
                  selectedProvider != null &&
                  _phoneNumberController.text.isNotEmpty) {
                Navigator.pop(context);
                _performTransaction(
                  'Mobile Top-Up',
                  -amount,
                  details: {
                    'provider': selectedProvider!,
                    'phone': _phoneNumberController.text,
                  },
                );
                _showSuccessAnimation('Top-Up Successful');
                _amountController.clear();
                _phoneNumberController.clear();
              }
            },
          ),
    );
  }

  void _payBill(String type) {
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Pay $type Bill',
            [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _textFieldDecoration('Amount'),
              ),
            ],
            () {
              final amount = double.tryParse(_amountController.text);
              if (amount != null && amount > 0 && amount <= _balance) {
                Navigator.pop(context);
                _performTransaction('$type Bill Payment', -amount);
                _showSuccessAnimation('Bill Paid Successfully');
                _amountController.clear();
              }
            },
          ),
    );
  }

  void _transferMoney() {
    double transferAmount = 0;
    showDialog(
      context: context,
      builder:
          (context) => _buildDialog(
            'Transfer Money',
            [
              TextField(
                controller: _recipientController,
                decoration: _textFieldDecoration('Recipient Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountNumberController,
                decoration: _textFieldDecoration('Account Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: _textFieldDecoration('Phone Number'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _textFieldDecoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: _textFieldDecoration('Amount'),
                onChanged:
                    (value) => transferAmount = double.tryParse(value) ?? 0,
              ),
            ],
            () {
              if (transferAmount > 0 &&
                  transferAmount <= _balance &&
                  _recipientController.text.isNotEmpty) {
                Navigator.pop(context);
                _showTransferAnimation(transferAmount);
              }
            },
            confirmLabel: 'Transfer',
          ),
    );
  }

  void _showTransferAnimation(double amount) {
    _animationController.reset();
    _animationController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => GestureDetector(
            onTap: () {}, // Prevent taps from dismissing
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.send_rounded,
                      size: 80,
                      color: Color(0xFF00B6B6),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Transferring \$${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Color(0xFF00B6B6)),
                  ],
                ),
              ),
            ),
          ),
    ).then((_) {
      if (mounted) {
        _performTransaction(
          'Money Transfer',
          -amount,
          details: {
            'recipient': _recipientController.text,
            'account': _accountNumberController.text,
            'phone': _phoneNumberController.text,
            'email': _emailController.text,
          },
        );
        _showSuccessAnimation('Transfer Successful');
        _amountController.clear();
        _recipientController.clear();
        _accountNumberController.clear();
        _phoneNumberController.clear();
        _emailController.clear();
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showSuccessAnimation(String message) {
    _animationController.reset();
    _animationController.forward();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => GestureDetector(
            onTap: () {}, // Prevent taps from dismissing
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    final dateStr = (tx['date'] as String?) ?? DateTime.now().toString();
    final safeDate =
        dateStr.length >= 16
            ? dateStr.substring(0, 16)
            : dateStr.padRight(16, ' ');
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Transaction Details',
                  style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              body: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Type',
                      tx['type'] ?? 'Unknown',
                      Icons.category,
                    ),
                    _buildDetailRow(
                      'Amount',
                      '\$${amount.abs().toStringAsFixed(2)}',
                      amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                      color: amount >= 0 ? Colors.green : Colors.red,
                    ),
                    _buildDetailRow('Date', safeDate, Icons.calendar_today),
                    if (tx['recipient'] != null)
                      _buildDetailRow(
                        'Recipient',
                        tx['recipient'],
                        Icons.person,
                      ),
                    if (tx['account'] != null)
                      _buildDetailRow(
                        'Account',
                        tx['account'],
                        Icons.account_balance,
                      ),
                    if (tx['phone'] != null)
                      _buildDetailRow('Phone', tx['phone'], Icons.phone),
                    if (tx['email'] != null)
                      _buildDetailRow('Email', tx['email'], Icons.email),
                    if (tx['source'] != null)
                      _buildDetailRow('Source', tx['source'], Icons.source),
                    if (tx['destination'] != null)
                      _buildDetailRow(
                        'Destination',
                        tx['destination'],
                        Icons.place,
                      ),
                    if (tx['provider'] != null)
                      _buildDetailRow(
                        'Provider',
                        tx['provider'],
                        Icons.network_cell,
                      ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).iconTheme.color,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _amountController.dispose();
    _recipientController.dispose();
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions:
            _isSelecting
                ? [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _deleteSelectedTransactions,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed:
                        () => setState(() {
                          _selectedTransactionIndices.clear();
                          _isSelecting = false;
                        }),
                  ),
                ]
                : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Wallet',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B6B6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Saved Cards',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ..._cards.map((card) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap: () => _setDefaultCard(_cards.indexOf(card)),
                    onLongPress: () => _showCardOptions(_cards.indexOf(card)),
                    child: _buildCardItem(
                      card['number'] as String? ?? 'Unknown',
                      card['name'] as String? ?? 'Unknown',
                      card['type'] as String? ?? 'Unknown',
                      card['isDefault'] as bool? ?? false,
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton('Add Card', Icons.add_card, _addCard),
                  _buildActionButton(
                    'Deposit',
                    Icons.account_balance_wallet,
                    _deposit,
                  ),
                  _buildActionButton('Withdraw', Icons.money_off, _withdraw),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    'Top-Up',
                    Icons.phone_android,
                    _mobileTopUp,
                  ),
                  _buildActionButton(
                    'Pay Bills',
                    Icons.receipt,
                    () => _showBillOptions(),
                  ),
                  _buildActionButton('Transfer', Icons.send, _transferMoney),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                  if (_isSelecting)
                    Text(
                      '${_selectedTransactionIndices.length} selected',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ..._transactions.asMap().entries.map((entry) {
                final index = entry.key;
                final tx = entry.value;
                final dateStr =
                    (tx['date'] as String?) ?? DateTime.now().toString();
                final safeDate =
                    dateStr.length >= 16
                        ? dateStr.substring(0, 16)
                        : dateStr.padRight(16, ' ');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    onTap:
                        _isSelecting
                            ? () => _toggleSelection(index)
                            : () => _showTransactionDetails(tx),
                    onLongPress: () {
                      if (!_isSelecting) {
                        setState(() {
                          _isSelecting = true;
                          _selectedTransactionIndices.add(index);
                        });
                      } else {
                        _toggleSelection(index);
                      }
                    },
                    child: _buildTransactionItem(
                      tx['type'] as String? ?? 'Unknown',
                      (tx['amount'] as num?)?.toDouble() ?? 0.0,
                      safeDate,
                      tx['recipient'] as String?,
                      _selectedTransactionIndices.contains(index),
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildDialog(
    String title,
    List<Widget> content,
    VoidCallback onConfirm, {
    String confirmLabel = 'Confirm',
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...content,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF00B6B6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B6B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildCardItem(
    String number,
    String name,
    String type,
    bool isDefault,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF777777), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            type == 'Visa' ? Icons.credit_card : Icons.payment_rounded,
            color:
                isDefault ? const Color(0xFF00B6B6) : const Color(0xFF777777),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$name ($type)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00B6B6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Default',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String type,
    double amount,
    String date,
    String? recipient,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : const Color(0xFF777777),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                color: amount >= 0 ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                  ),
                  if (recipient != null)
                    Text(
                      'To: $recipient',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Text(
            amount >= 0
                ? '+\$${amount.toStringAsFixed(2)}'
                : '-\$${(-amount).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: amount >= 0 ? const Color(0xFF00B6B6) : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B6B6),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showBillOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder:
          (context) => _buildBottomSheet([
            ListTile(
              leading: const Icon(
                Icons.electrical_services,
                color: Color(0xFF00B6B6),
              ),
              title: const Text(
                'Electricity Bill',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _payBill('Electricity');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.local_gas_station,
                color: Color(0xFF00B6B6),
              ),
              title: const Text(
                'Gas Bill',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _payBill('Gas');
              },
            ),
          ]),
    );
  }
}
