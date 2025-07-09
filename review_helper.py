import os
import re

def analyze_dart_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        code = f.read()
    suggestions = []

    # Unit Test var mı?
    if "test(" not in code and "group(" not in code:
        suggestions.append("❌ Unit test bulunamadı. Fonksiyonlar için test eklemelisin.")

    # Type hint (Dart'ta tipler var mı?)
    if re.search(r"dynamic |var ", code):
        suggestions.append("⚠️  'dynamic' veya 'var' çok fazla kullanılmış. Daha açık tipler kullanmalısın.")

    # Logging
    if "print(" in code and "logger" not in code:
        suggestions.append("⚠️  print() yerine logger kullanmak daha iyi olur.")

    # Dokümantasyon
    if not re.search(r'///', code):
        suggestions.append("❌ Fonksiyonlar için dokümantasyon (///) eksik.")

    # Error handling
    if "try" not in code or "catch" not in code:
        suggestions.append("⚠️  Hata yönetimi (try/catch) eksik veya az kullanılmış.")

    # Mocking (test dosyalarında)
    if filepath.endswith("_test.dart") and "mock" not in code:
        suggestions.append("⚠️  Testlerde mocking kullanılmamış. Dış bağımlılıkları mock'la.")

    # Refactoring (uzun fonksiyonlar)
    if any(len(fn.split('\n')) > 40 for fn in code.split("void ") if "{" in fn):
        suggestions.append("⚠️  Çok uzun fonksiyonlar var. Küçük fonksiyonlara bölmeyi düşün.")

    return suggestions

def main():
    report = []
    for root, dirs, files in os.walk("."):
        for file in files:
            if file.endswith(".dart"):
                path = os.path.join(root, file)
                suggestions = analyze_dart_file(path)
                if suggestions:
                    report.append(f"### {path}\n" + "\n".join(suggestions))

    if not report:
        print("✅ Kodun gayet iyi görünüyor!")
    else:
        print("\n\n".join(report))

if __name__ == "__main__":
    main()
