import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final tickets = await _apiService.getPatientTickets();
      
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load tickets: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'claimed':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPriorityBadge(int priority) {
    Color color;
    String label;
    
    if (priority == 2) {
      color = Colors.red;
      label = "High Risk";
    } else if (priority == 1) {
      color = Colors.orange;
      label = "Medium Risk";
    } else {
      color = Colors.green;
      label = "Low Risk";
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTickets,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No tickets found. Take a photo of a skin lesion to create a ticket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView.builder(
                    itemCount: _tickets.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      
                      // Improved image URL extraction
                      String? imageUrl;
                      if (ticket['medical_image_details'] != null) {
                        // Try to get the image_url first (which is the full URL)
                        imageUrl = ticket['medical_image_details']['image_url'];
                        
                        // If image_url is not available, try image_path
                        if (imageUrl == null || imageUrl.isEmpty) {
                          final imagePath = ticket['medical_image_details']['image_path'];
                          if (imagePath != null && imagePath.isNotEmpty) {
                            imageUrl = imagePath;
                          }
                        }
                      }
                      
                      final status = ticket['status'] ?? 'pending';
                      final createdAt = DateTime.parse(ticket['created_at']);
                      final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(createdAt);
                      final priority = ticket['priority'] ?? 0;
                      final diagnosisResult = ticket['diagnosis_result'] ?? 'Unknown';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with Ticket ID and Date
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ticket #${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Image Preview - Improved image loading
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              child: _buildNetworkImage(imageUrl),
                            ),
                            
                            // Ticket Info
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Status and Priority Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(status),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Status: ${status[0].toUpperCase() + status.substring(1)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _getStatusColor(status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildPriorityBadge(priority),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Diagnosis Result
                                  Text(
                                    'Diagnosis: $diagnosisResult',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: diagnosisResult == 'MALIGNANT' 
                                          ? Colors.red 
                                          : Colors.black87,
                                    ),
                                  ),
                                  
                                  // "View Details" button removed as requested
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
  
  Widget _buildNetworkImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(
        child: Text(
          'No image available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    // Ensure the URL has a proper scheme
    String fullImageUrl = imageUrl;
    if (!imageUrl.startsWith('http')) {
      // If it's a relative path, create a complete URL
      final baseUrl = _apiService.baseUrl;
      fullImageUrl = baseUrl.endsWith('/') 
          ? '$baseUrl${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}'
          : '$baseUrl${imageUrl.startsWith('/') ? imageUrl : '/$imageUrl'}';
    }
    
    return Image.network(
      fullImageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error for URL: $fullImageUrl');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(
                'Unable to load image',
                style: TextStyle(color: Colors.red[700]),
              ),
              const SizedBox(height: 4),
              Text(
                '${error.toString().substring(0, error.toString().length > 50 ? 50 : error.toString().length)}...',
                style: TextStyle(color: Colors.red[300], fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}