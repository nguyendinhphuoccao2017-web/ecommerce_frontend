String formatCardHolderName(String rawName) {
  if (rawName.isEmpty) return "UNKNOWN HOLDER";

  // 1. Loại bỏ dữ liệu rác (số, kí tự đặc biệt, gạch dưới như _CNTT2_, số tài khoản test)
  String cleanName = rawName.replaceAll(RegExp(r'[^a-zA-ZàáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ\s]'), '').trim();

  // 2. Bảng chuyển đổi Tiếng Việt có dấu thành KHÔNG DẤU
  const vietnameseSigns = "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđĐ";
  const englishSigns    = "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydD";
  
  for (int i = 0; i < vietnameseSigns.length; i++) {
    cleanName = cleanName.replaceAll(vietnameseSigns[i], englishSigns[i]);
  }

  // 3. Tách chuỗi tên thành các từ để rút gọn (Họ + Tên chính)
  List<String> words = cleanName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  String shortName = "";
  if (words.length >= 2) {
    // Lấy từ đầu tiên (Họ) và từ cuối cùng (Tên chính)
    shortName = "${words.first} ${words.last}";
  } else if (words.isNotEmpty) {
    shortName = words.first;
  } else {
    shortName = "UNKNOWN HOLDER";
  }

  // 4. IN HOA TOÀN BỘ chuẩn thẻ quốc tế
  return shortName.toUpperCase();
}
