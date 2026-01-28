import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:franchisemarketturkiye/app/app_theme.dart';
import 'package:franchisemarketturkiye/viewmodels/login_view_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:franchisemarketturkiye/views/widgets/webview_view.dart';

class LoginView extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginView({super.key, this.onLoginSuccess});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
    _viewModel.addListener(_onViewModelUpdate);
  }

  void _onViewModelUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_viewModel.isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SvgPicture.asset('assets/logo.svg', height: 48),
              ),
            ),
            // Tabs
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_viewModel.isLogin) _viewModel.toggleAuthMode();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _viewModel.isLogin
                            ? AppTheme.primaryColor
                            : Colors.white,
                        border: _viewModel.isLogin
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          'GİRİŞ',
                          style: TextStyle(
                            color: _viewModel.isLogin
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_viewModel.isLogin) _viewModel.toggleAuthMode();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: !_viewModel.isLogin
                            ? AppTheme.primaryColor
                            : Colors.white,
                        border: !_viewModel.isLogin
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          'KAYIT',
                          style: TextStyle(
                            color: !_viewModel.isLogin
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (_viewModel.isLogin) _buildLoginForm() else _buildRegisterForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('E-POSTA ADRESİNİZ'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.emailController,
          hintText: 'E-Posta Adresinizi Giriniz',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enableSuggestions: false,
          autocorrect: false,
        ),
        const SizedBox(height: 24),
        _buildTextFieldLabel('ŞİFRENİZ'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.passwordController,
          hintText: 'Şifrenizi Giriniz',
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WebViewView(
                    url: 'https://franchisemarketturkiye.com/sifremi-unuttum',
                    title: 'Şifremi Unuttum',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Şifremi Unuttum?',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildErrorMessage(),
        _buildActionButton('Giriş Yap', () async {
          final success = await _viewModel.login();
          if (success && mounted) {
            widget.onLoginSuccess?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Başarıyla giriş yapıldı'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldLabel('AD *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.firstNameController,
          hintText: 'Adınızı Giriniz',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('SOYAD *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.lastNameController,
          hintText: 'Soyadınızı Giriniz',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('TELEFON *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.phoneController,
          hintText: '05xx xxx xx xx',
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 16,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('E-POSTA *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.emailController,
          hintText: 'E-Posta Adresinizi Giriniz',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enableSuggestions: false,
          autocorrect: false,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('ŞİFRE *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.passwordController,
          hintText: 'Şifrenizi Giriniz',
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextFieldLabel('ŞİFRE TEKRAR *'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _viewModel.passwordConfirmController,
          hintText: 'Şifrenizi Tekrar Giriniz',
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _viewModel.termsAccepted,
                onChanged: _viewModel.setTermsAccepted,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  text: 'Üyelik Sözleşmesi’ni ',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                  children: [
                    TextSpan(
                      text: 'okuduğumu ve kabul ettiğimi ',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: 'beyan ederim.'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _viewModel.newsletter,
                onChanged: _viewModel.setNewsletter,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Bülten Aboneliği',
              style: TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildErrorMessage(),
        _buildActionButton('Kayıt Ol', () async {
          final success = await _viewModel.register();
          if (success && mounted) {
            // Navigator.pop(context); // Maybe redirect to login or show success?
            // Usually after register, auto login or ask to login.
            // Prompt says "Giriş" and response has success logic.
            // For now, let's show success and maybe switch to login or pop.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kayıt başarılı! Lütfen giriş yapınız.'),
                backgroundColor: Colors.green,
              ),
            );
            _viewModel.toggleAuthMode(); // Switch to login after success
          }
        }),
      ],
    );
  }

  Widget _buildErrorMessage() {
    if (_viewModel.errorMessage == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _viewModel.errorMessage!,
        style: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    bool enableSuggestions = true,
    bool autocorrect = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _viewModel.isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: _viewModel.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
