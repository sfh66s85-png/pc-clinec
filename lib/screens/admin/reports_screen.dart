import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/pdf_service.dart';
import 'dart:ui';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<OrderModel>? _reportOrders;
  bool _isLoading = false;

  Future<void> _fetchReportData() async {
    setState(() => _isLoading = true);
    final orderService = OrderService();
    // Adjusting start and end dates to cover full days
    DateTime start = DateTime(_startDate.year, _startDate.month, _startDate.day, 0, 0, 0);
    DateTime end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);
    
    final orders = await orderService.getOrdersInDateRange(start, end);
    setState(() {
      _reportOrders = orders;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  double get _totalSales => _reportOrders?.fold(0.0, (sum, order) => sum! + order.totalAmount) ?? 0.0;
  int get _orderCount => _reportOrders?.length ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Glassmorphism Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.withOpacity(0.1), Colors.blueGrey.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                _buildDatePickers(),
                SizedBox(height: 20),
                _isLoading 
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : Expanded(
                      child: Column(
                        children: [
                          _buildSummaryCards(),
                          SizedBox(height: 20),
                          Expanded(child: _buildOrdersList()),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'تقارير المبيعات',
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.teal.shade800,
      ),
    );
  }

  Widget _buildDatePickers() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              _dateButton("من: ", _startDate, (date) {
                setState(() => _startDate = date);
                _fetchReportData();
              }),
              SizedBox(width: 20),
              _dateButton("إلى: ", _endDate, (date) {
                setState(() => _endDate = date);
                _fetchReportData();
              }),
              Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  if (_reportOrders != null && _reportOrders!.isNotEmpty) {
                    PdfService().generateSalesReport(
                      orders: _reportOrders!,
                      startDate: _startDate,
                      endDate: _endDate,
                      totalSales: _totalSales,
                    );
                  }
                },
                icon: Icon(Icons.picture_as_pdf),
                label: Text('تصدير PDF', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _fetchReportData,
                icon: Icon(Icons.refresh),
                label: Text('تحديث', style: TextStyle(fontFamily: 'Cairo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onSelected(picked);
      },
      child: Row(
        children: [
          Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          Text(intl.DateFormat('yyyy-MM-dd').format(date), style: TextStyle(fontFamily: 'Cairo')),
          Icon(Icons.calendar_today, size: 16, color: Colors.teal),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _summaryCard('إجمالي المبيعات', '${_totalSales.toStringAsFixed(2)} ج.م', Icons.attach_money, Colors.green),
        SizedBox(width: 20),
        _summaryCard('عدد الطلبات', '$_orderCount', Icons.shopping_bag, Colors.blue),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.black54)),
                    Text(value, style: TextStyle(fontFamily: 'Cairo', fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_reportOrders == null || _reportOrders!.isEmpty) {
      return Center(child: Text('لا توجد بيانات لهذه الفترة', style: TextStyle(fontFamily: 'Cairo')));
    }
    return ListView.builder(
      itemCount: _reportOrders!.length,
      itemBuilder: (context, index) {
        final order = _reportOrders![index];
        return Card(
          margin: EdgeInsets.only(bottom: 10),
          color: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('طلب #${order.orderId.substring(0, 8)}', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${intl.DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)} - ${order.customerName}'),
            trailing: Text('${order.totalAmount.toStringAsFixed(2)} ج.م', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}
