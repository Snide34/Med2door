import 'package:flutter/material.dart';
import 'package:med2door/models/order.dart';
import 'package:med2door/utils/app_colours.dart' as app_colors;

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedFilter = 'All';
  String? _expandedOrderId;

  final List<Order> _orderHistoryData = [
    const Order(
        id: 'MD123456',
        date: 'Dec 10, 2024',
        status: 'Delivered',
        totalItems: 3,
        total: 425,
        deliveryAddress: '123 Main Street, City - 123456',
        paymentMethod: 'UPI',
        items: [
          OrderItem(id: '1', name: 'Paracetamol 500mg', quantity: 2, price: 45, image: 'https://i.imgur.com/8f8Y4bC.png'),
          OrderItem(id: '2', name: 'Vitamin C Tablets', quantity: 1, price: 120, image: 'https://i.imgur.com/8f8Y4bC.png'),
          OrderItem(id: '3', name: 'Omega-3 Capsules', quantity: 1, price: 215, image: 'https://i.imgur.com/8f8Y4bC.png'),
        ]),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orderHistoryData.where((order) => _selectedFilter == 'All' || order.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: app_colors.kGrey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: app_colors.kWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Order History', style: TextStyle(color: app_colors.kWhite, fontWeight: FontWeight.w600)),
        backgroundColor: app_colors.kPrimaryTealDark,
        elevation: 1,
        shadowColor: app_colors.kGrey.withAlpha(50),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const statusFilters = ['All', 'Delivered', 'In Progress', 'Cancelled'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      color: app_colors.kWhite,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusFilters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  }
                },
                selectedColor: app_colors.kPrimaryTeal,
                labelStyle: TextStyle(color: isSelected ? app_colors.kWhite : app_colors.kPrimaryTealDark),
                backgroundColor: app_colors.kWhite,
                shape: StadiumBorder(side: BorderSide(color: isSelected ? app_colors.kPrimaryTeal : app_colors.kBorderGrey)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: app_colors.kGrey),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All' ? 'You have no order history' : 'No $_selectedFilter orders found',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: app_colors.kGrey800),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final isExpanded = _expandedOrderId == order.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: app_colors.kGrey.withAlpha(50),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.id, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${order.date} • ${order.totalItems} items', style: const TextStyle(color: app_colors.kTextGrey)),
                    Text('₹${order.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: order.items.map((item) => _buildOrderItem(item)).toList(),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.spaceAround,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _expandedOrderId = isExpanded ? null : order.id;
                    });
                  },
                  child: Text(isExpanded ? 'Hide Items' : 'View Items'),
                ),
                if (order.status == 'Delivered')
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/receipt', arguments: order),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View Receipt'),
                  ),
                if (order.status == 'In Progress')
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed('/order-tracking', arguments: order.id),
                    icon: const Icon(Icons.track_changes),
                    label: const Text('Track Order'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (item.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.image!, width: 50, height: 50, fit: BoxFit.cover),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Qty: ${item.quantity}'),
              ],
            ),
          ),
          Text('₹${item.price.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color textColor;
    switch (status) {
      case 'Delivered':
        color = app_colors.kSuccessGreen.withAlpha(50);
        textColor = app_colors.kSuccessGreen;
        break;
      case 'In Progress':
        color = app_colors.kBlue50;
        textColor = Colors.blue.shade600;
        break;
      case 'Cancelled':
        color = app_colors.kErrorRed.withAlpha(50);
        textColor = app_colors.kErrorRed;
        break;
      default:
        color = app_colors.kGrey50;
        textColor = app_colors.kGrey600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}
