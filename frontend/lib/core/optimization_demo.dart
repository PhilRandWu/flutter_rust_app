import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/network_optimizer.dart';
import 'package:frontend/core/performance/performance_monitor.dart';
import 'package:frontend/src/rust/api/crypto.dart';
import 'package:frontend/src/rust/api/performance.dart';

class OptimizationDemo extends StatefulWidget {
  const OptimizationDemo({super.key});

  @override
  State<OptimizationDemo> createState() => _OptimizationDemoState();
}

class _OptimizationDemoState extends State<OptimizationDemo> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _result = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _runCryptoDemo() async {
    setState(() => _isLoading = true);
    
    PerformanceMonitor.startTimer('crypto_demo');
    
    // Hash password using Rust
    final password = _passwordController.text;
    final hashedPassword = hashPassword(password: password);
    
    // Generate secure token
    final token = generateSecureToken(length: 32);
    
    // SHA256 hash
    final input = _inputController.text;
    final hash = sha256Hash(input: input);
    
    PerformanceMonitor.stopTimer('crypto_demo');
    
    setState(() {
      _result = '''Crypto Demo Results:
Password Hash: ${hashedPassword.substring(0, 20)}...
Secure Token: $token
SHA256 Hash: ${hash.substring(0, 20)}...
Time: ${PerformanceMonitor.getAverageTime('crypto_demo').toStringAsFixed(2)}ms''';
      _isLoading = false;
    });
  }

  Future<void> _runPerformanceDemo() async {
    setState(() => _isLoading = true);
    
    // Fibonacci calculation
    final fibResult = PerformanceMonitor.computeFibonacci(40);
    
    // Large data processing
    final largeData = 'Lorem ipsum dolor sit amet, ' * 1000;
    final processedData = PerformanceMonitor.processLargeData(largeData);
    
    // Batch string processing
    final strings = List.generate(100, (i) => 'string_$i');
    final processedStrings = PerformanceMonitor.batchProcessStrings(strings);
    
    setState(() {
      _result = '''Performance Demo Results:
Fibonacci(40): $fibResult
Large Data Processed: ${processedData.length} characters
Batch Processed: ${processedStrings.length} strings
Fibonacci Time: ${PerformanceMonitor.getAverageTime('fibonacci_40').toStringAsFixed(2)}ms
Data Processing Time: ${PerformanceMonitor.getAverageTime('process_large_data').toStringAsFixed(2)}ms''';
      _isLoading = false;
    });
  }

  Future<void> _runNetworkDemo() async {
    setState(() => _isLoading = true);
    
    PerformanceMonitor.startTimer('network_demo');
    
    // Email validation
    final email = _inputController.text;
    final isValid = NetworkOptimizer.validateEmail(email);
    
    // Input sanitization
    final sanitized = NetworkOptimizer.sanitizeUserInput(email);
    
    // Data compression
    final testData = 'Test data for compression ' * 100;
    final compressed = NetworkOptimizer.compressAndEncode(testData);
    final decompressed = NetworkOptimizer.decompressAndDecode(compressed);
    
    // Cache demo
    NetworkOptimizer.cacheApiResponse('test_key', testData, ttlSeconds: 60);
    final cached = NetworkOptimizer.getCachedResponse('test_key');
    
    PerformanceMonitor.stopTimer('network_demo');
    
    setState(() {
      _result = '''Network Demo Results:
Email Valid: $isValid
Sanitized Input: $sanitized
Compression Ratio: ${((compressed.length / testData.length) * 100).toStringAsFixed(1)}%
Cache Hit: ${cached != null}
Time: ${PerformanceMonitor.getAverageTime('network_demo').toStringAsFixed(2)}ms''';
      _isLoading = false;
    });
  }

  void _showMetrics() {
    final metrics = PerformanceMonitor.getAllMetrics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Metrics'),
        content: SingleChildScrollView(
          child: Text(metrics.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              PerformanceMonitor.clearMetrics();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rust Optimization Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showMetrics,
            tooltip: 'Show Performance Metrics',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Input Text',
                hintText: 'Enter text for processing',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password for hashing',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runCryptoDemo,
                    child: const Text('Crypto Demo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runPerformanceDemo,
                    child: const Text('Performance Demo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runNetworkDemo,
                    child: const Text('Network Demo'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}