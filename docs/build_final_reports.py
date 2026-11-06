# -*- coding: utf-8 -*-
"""Báo cáo cá nhân CT484 — CafeSpot. Ảnh từ emulator và bộ kiểm thử Flutter."""
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Pt, RGBColor, Twips

BASE = Path(__file__).resolve().parents[1]
SHOT = BASE / "docs" / "screenshots" / "final"
OUT = BASE / "docs"
ROOT = BASE.parent
GITHUB = "https://github.com/vuongdc24v7x414/CT484_CafeSpot_ThongVuong"
FONT = "Times New Roman"


def _rfonts(run):
    rpr = run._element.get_or_add_rPr()
    fonts = rpr.find(qn("w:rFonts"))
    if fonts is None:
        fonts = OxmlElement("w:rFonts")
        rpr.append(fonts)
    for attr in ("w:ascii", "w:hAnsi", "w:eastAsia", "w:cs"):
        fonts.set(qn(attr), FONT)


def font(run, size=13, bold=False, italic=False, color=None):
    run.font.name = FONT
    _rfonts(run)
    run.font.size = Pt(size)
    run.bold = bold
    run.italic = italic
    run.font.color.rgb = color or RGBColor(0x22, 0x22, 0x22)


def style_doc(doc: Document):
    normal = doc.styles["Normal"]
    normal.font.name = FONT
    normal.font.size = Pt(13)
    normal.font.color.rgb = RGBColor(0x22, 0x22, 0x22)
    pf = normal.paragraph_format
    pf.line_spacing = 1.15
    pf.space_after = Pt(6)
    pf.space_before = Pt(0)
    rpr = normal.element.get_or_add_rPr()
    fonts = rpr.find(qn("w:rFonts"))
    if fonts is None:
        fonts = OxmlElement("w:rFonts")
        rpr.append(fonts)
    for attr in ("w:ascii", "w:hAnsi", "w:eastAsia", "w:cs"):
        fonts.set(qn(attr), FONT)

    for style_name, size in (("Heading 1", 14), ("Heading 2", 13)):
        st = doc.styles[style_name]
        st.font.name = FONT
        st.font.size = Pt(size)
        st.font.bold = True
        st.font.color.rgb = RGBColor(0x2C, 0x21, 0x18)
        st.font.italic = False
        rpr = st.element.get_or_add_rPr()
        fonts = rpr.find(qn("w:rFonts"))
        if fonts is None:
            fonts = OxmlElement("w:rFonts")
            rpr.append(fonts)
        for attr in ("w:ascii", "w:hAnsi", "w:eastAsia", "w:cs"):
            fonts.set(qn(attr), FONT)
        st.paragraph_format.space_before = Pt(14)
        st.paragraph_format.space_after = Pt(6)
        st.paragraph_format.line_spacing = 1.15

    sec = doc.sections[0]
    sec.page_width = Cm(21.0)
    sec.page_height = Cm(29.7)
    sec.left_margin = Cm(2.2)
    sec.right_margin = Cm(1.8)
    sec.top_margin = Cm(1.6)
    sec.bottom_margin = Cm(1.6)
    sec.header_distance = Cm(0.6)
    sec.footer_distance = Cm(0.6)


def shade(cell, hex_color: str):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), hex_color)
    shd.set(qn("w:val"), "clear")
    tcPr.append(shd)


def set_cell_border(cell):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement("w:tcBorders")
    for edge in ("top", "left", "bottom", "right"):
        el = OxmlElement(f"w:{edge}")
        el.set(qn("w:val"), "single")
        el.set(qn("w:sz"), "4")
        el.set(qn("w:color"), "B0B0B0")
        tcBorders.append(el)
    tcPr.append(tcBorders)


def para(doc, text, *, size=13, bold=False, italic=False, align="left", indent=False, space_after=6, space_before=0):
    p = doc.add_paragraph()
    p.alignment = {
        "left": WD_ALIGN_PARAGRAPH.LEFT,
        "center": WD_ALIGN_PARAGRAPH.CENTER,
        "justify": WD_ALIGN_PARAGRAPH.JUSTIFY,
    }[align]
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.space_before = Pt(space_before)
    p.paragraph_format.line_spacing = 1.15
    if indent:
        p.paragraph_format.first_line_indent = Cm(0.8)
    if text.startswith("Ảnh chức năng") or text.startswith("Chi tiết cài đặt"):
        p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    font(run, size=size, bold=bold, italic=italic)
    return p


def rich(doc, parts, *, align="justify", indent=False, space_after=6):
    """parts: list of (text, bold, italic) or plain str."""
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY if align == "justify" else WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    if indent:
        p.paragraph_format.first_line_indent = Cm(0.8)
    for part in parts:
        if isinstance(part, str):
            text, bold, italic = part, False, False
        else:
            text, bold, italic = part
        run = p.add_run(text)
        font(run, bold=bold, italic=italic)
    return p


def label_line(doc, label, text):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.space_before = Pt(1)
    p.paragraph_format.line_spacing = 1.15
    a = p.add_run(label)
    font(a, size=13, bold=True)
    b = p.add_run(text)
    font(b, size=13)
    return p


def bullet(doc, text, *, bold_prefix=None):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Cm(0.75)
    p.paragraph_format.first_line_indent = Cm(-0.35)
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.line_spacing = 1.08
    dot = p.add_run("– ")
    font(dot, size=13)
    if bold_prefix:
        r = p.add_run(bold_prefix)
        font(r, size=13, bold=True)
    r2 = p.add_run(text)
    font(r2, size=13)
    return p


def add_table(doc, headers, rows, widths):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.autofit = False
    for i, h in enumerate(headers):
        cell = table.rows[0].cells[i]
        cell.text = ""
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        run = p.add_run(h)
        font(run, size=12, bold=True)
        shade(cell, "F4F1EC")
        set_cell_border(cell)
        cell.width = Cm(widths[i])
    for r_i, row in enumerate(rows):
        for c_i, val in enumerate(row):
            cell = table.rows[r_i + 1].cells[c_i]
            cell.text = ""
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            run = p.add_run(val)
            font(run, size=12)
            set_cell_border(cell)
            cell.width = Cm(widths[c_i])
    doc.add_paragraph().paragraph_format.space_after = Pt(2)
    return table


def picture(doc, name, caption, width_cm):
    path = SHOT / name
    if not path.exists():
        para(doc, f"(Thiếu ảnh {name})", italic=True)
        return
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(2)
    p.paragraph_format.keep_with_next = True
    run = p.add_run()
    run.add_picture(str(path), width=Cm(width_cm))
    cap = doc.add_paragraph()
    cap.alignment = WD_ALIGN_PARAGRAPH.CENTER
    cap.paragraph_format.space_after = Pt(8)
    cap.paragraph_format.space_before = Pt(0)
    r = cap.add_run(caption)
    font(r, size=12, italic=True, color=RGBColor(0x44, 0x44, 0x44))


def header_footer(doc, mssv, name):
    header = doc.sections[0].header
    header.is_linked_to_previous = False
    hp = header.paragraphs[0]
    hp.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = hp.add_run(f"CafeSpot  ·  {mssv}  ·  {name}")
    font(run, size=10, italic=True, color=RGBColor(0x66, 0x66, 0x66))

    footer = doc.sections[0].footer
    footer.is_linked_to_previous = False
    fp = footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r1 = fp.add_run("Trang ")
    font(r1, size=11)
    # PAGE field
    run = fp.add_run()
    font(run, size=11)
    fld1 = OxmlElement("w:fldChar")
    fld1.set(qn("w:fldCharType"), "begin")
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = " PAGE "
    fld2 = OxmlElement("w:fldChar")
    fld2.set(qn("w:fldCharType"), "end")
    run._r.append(fld1)
    run._r.append(instr)
    run._r.append(fld2)


def cover(doc, mssv, name, assigned_lines):
    para(doc, "BÁO CÁO DỰ ÁN CUỐI KỲ", size=16, bold=True, align="center", space_after=2)
    para(doc, "Học kỳ 1, năm học 2026–2027", size=13, align="center", space_after=0)
    para(doc, "CT484 — Phát triển ứng dụng di động", size=13, bold=True, align="center", space_after=10)
    para(doc, "Tên ứng dụng: CafeSpot (review quán cà phê)", align="center", space_after=2)
    para(doc, f"MSSV: {mssv}", align="center", space_after=0)
    para(doc, f"Họ và tên: {name}", align="center", space_after=0)
    para(doc, "Lớp học phần: CT484", align="center", space_after=2)
    para(doc, f"GitHub: {GITHUB}", size=12, align="center", space_after=10)
    for line in assigned_lines:
        para(doc, line, align="justify", indent=True, space_after=6)


def function_block(doc, title, desc_parts, shot, caption, width, details):
    doc.add_heading(title, level=1)
    rich(doc, desc_parts, indent=True)
    para(doc, "Ảnh chức năng/giao diện:", bold=True, space_after=2)
    picture(doc, shot, caption, width)
    para(doc, "Chi tiết cài đặt:", bold=True, space_after=2)
    for kind, text in details:
        if kind == "lib":
            name, role = text
            bullet(doc, role, bold_prefix=f"{name}: ")
        elif kind == "line":
            label, body = text
            label_line(doc, label, body)
        else:
            bullet(doc, text)


def build_thong():
    doc = Document()
    style_doc(doc)
    header_footer(doc, "BK24V7X703", "Lưu Minh Thông")
    cover(
        doc,
        "BK24V7X703",
        "Lưu Minh Thông",
        [
            "Trong dự án nhóm gồm 2 thành viên, em được phân công phát triển các phần: (1) Splash, (2) Trang chủ, (3) chi tiết quán, (4) form thêm/sửa quán, (5) điều hướng go_router, (6) SQLite. Bạn Nguyễn Quốc Vương làm Yêu thích, Đánh giá của tôi, Tìm kiếm, Cài đặt, thông báo cục bộ và giao diện responsive.",
            "CafeSpot là ứng dụng Flutter để xem quán cà phê, thêm/sửa/xóa, chấm sao và lưu yêu thích. Không có server. Dữ liệu nằm trong file SQLite trên máy. Em chạy và chụp ảnh trên Android emulator.",
        ],
    )

    doc.add_heading("Kiến trúc em dựng cho phần dữ liệu", level=1)
    para(
        doc,
        "Màn hình không gọi SQL trực tiếp. Luồng đi một chiều như sau:",
        indent=True,
    )
    add_table(
        doc,
        ["Tầng", "Làm gì"],
        [
            ["UI (Screen)", "Vẽ Scaffold, nhận thao tác, gọi hàm của Provider."],
            ["Provider", "CafeProvider giữ danh sách quán, yêu thích, review. Đổi dữ liệu thì notifyListeners."],
            ["Repository", "CafeRepository viết câu query, thêm/sửa/xóa, tính lại điểm trung bình."],
            ["DatabaseHelper", "Mở file cafe_spot.db, tạo bảng lần đầu, seed 4 quán mẫu."],
            ["SQLite", "File lưu trên máy. Hai bảng cafes và reviews."],
        ],
        [4.2, 12.2],
    )
    para(
        doc,
        "Trên web sqflite không chạy, nên CafeRepository thấy kIsWeb thì dùng MemoryStore tạm. Bản em demo là bản Android, dữ liệu thật nằm trong cafe_spot.db.",
        indent=True,
    )

    function_block(
        doc,
        "Chức năng 1. Màn hình Splash",
        [
            "Màn này chỉ hiện lúc vừa mở app. Nền nâu, logo tách cà phê, chữ CafeSpot và dòng “CT484 · Nhóm Thông & Vương”, phía dưới có vòng xoay. Em không cho nhảy sang trang chủ ngay. Trong initState em đợi cả ba việc: SettingsProvider.load(), CafeProvider.load() và một delay 1,4 giây. Xong hết mới context.go('/home'). Delay này để file SQLite kịp tạo và seed, không thì trang chủ mở ra lúc danh sách còn trống.",
        ],
        "splash.png",
        "Hình 1. Splash của CafeSpot, chụp trên emulator",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, Center, Column, Image.asset, Text, CircularProgressIndicator.")),
            ("line", ("Widget đặc biệt: ", "Không. Logo lấy từ assets/images/splash_logo.png.")),
            ("lib", ("provider", "gọi load() của SettingsProvider và CafeProvider trước khi rời màn này.")),
            ("lib", ("go_router", "context.go('/home') sau khi dữ liệu đã sẵn sàng.")),
            ("line", ("Quản lý trạng thái: ", "Splash không giữ state nghiệp vụ. Nó chỉ chờ future xong rồi điều hướng.")),
            ("line", ("Đọc/lưu dữ liệu: ", "Kích hoạt đọc SharedPreferences (cài đặt) và mở cafe_spot.db (quán, review).")),
        ],
    )

    function_block(
        doc,
        "Chức năng 2. Trang chủ",
        [
            "Trang chủ là danh sách quán, xếp rating cao lên trước. Hàng chip Tất cả / Chuỗi / Specialty / Local để lọc. Bấm một thẻ thì mở chi tiết quán đó. Nút trái tim trên ảnh đổi yêu thích. Nút Thêm quán đẩy sang form. Icon kính lúp trên AppBar đẩy sang /search, màn này bạn Vương làm.",
            " Trên điện thoại lưới chỉ có 1 cột. Hàm gridCountForWidth tăng số cột khi màn rộng hơn (2 cột từ 520, 3 từ 750, 4 từ 1100).",
        ],
        "home.png",
        "Hình 2. Trang chủ, lọc “Tất cả”, thanh điều hướng 4 tab",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, GridView.builder, FilterChip, FloatingActionButton.extended, LayoutBuilder, SingleChildScrollView.")),
            ("line", ("Widget đặc biệt: ", "CafeCard (ảnh, tên, địa chỉ, sao, chip danh mục, nút tim).")),
            ("lib", ("provider", "watch CafeProvider để lấy cafes, category và gọi setFilter / toggleFavorite.")),
            ("lib", ("go_router", "context.push('/cafe/${id}'), push('/cafe-form'), push('/search').")),
            ("line", ("Quản lý trạng thái: ", "CafeProvider (ChangeNotifier). Bộ lọc category nằm trong provider, không để local state của Home.")),
            ("line", ("Đọc/lưu dữ liệu: ", "CafeRepository.getCafes đọc bảng cafes, orderBy rating DESC, created_at DESC. Lọc danh mục thì thêm category = ?.")),
        ],
    )

    function_block(
        doc,
        "Chức năng 3. Chi tiết quán",
        [
            "Khi người dùng chọn một quán, ứng dụng truyền id của quán qua pathParameters để mở đúng trang chi tiết. Route là /cafe/:id. Em lấy id bằng int.parse(state.pathParameters['id']!) rồi đưa vào CafeDetailScreen.",
            " Trang hiện ảnh, tên, địa chỉ, số sao, danh mục và mô tả. Trên AppBar có tim, bút sửa và thùng rác. Xóa thì hỏi AlertDialog trước, đồng ý mới xóa quán cùng review của quán đó. Phía dưới là chỗ viết đánh giá: bấm sao, gõ nội dung, bấm Gửi. Ngày giờ review em format bằng DateFormat('dd/MM/yyyy HH:mm') của intl, không tự nối chuỗi.",
        ],
        "detail.png",
        "Hình 3. Chi tiết Garden Beans, mở bằng route /cafe/:id",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, ListView, Image.network, TextField, AlertDialog, IconButton, FilledButton.icon.")),
            ("line", ("Widget đặc biệt: ", "RatingStars. Vừa vẽ sao theo điểm, vừa cho chọn số sao khi onChanged khác null.")),
            ("lib", ("go_router", "nhận id trên path; nút Sửa thì push('/cafe-form', extra: cafe).")),
            ("lib", ("provider", "getById, reviewsOf, toggleFavorite, addReview, deleteCafe.")),
            ("lib", ("intl", "định dạng created_at thành dd/MM/yyyy HH:mm cho người dùng đọc.")),
            ("lib", ("flutter_local_notifications", "sau khi gửi review, nếu người dùng đang bật thông báo thì nhờ NotificationService hiện một dòng. Phần plugin này bạn Vương viết, em chỉ gọi.")),
            ("line", ("Quản lý trạng thái: ", "State cục bộ của màn (_cafe, _reviews, _rating, TextEditingController). Ghi xong thì gọi provider rồi _load() lại.")),
            ("line", ("Đọc/lưu dữ liệu: ", "Đọc 1 dòng cafes theo id và các review có cafe_id trùng. Gửi review thì INSERT vào reviews, repository tính AVG(rating) rồi UPDATE cột rating của quán.")),
        ],
    )

    function_block(
        doc,
        "Chức năng 4. Form thêm / sửa quán",
        [
            "Thêm mới và sửa dùng chung một màn, route /cafe-form. Thêm thì extra = null, các ô trống, URL ảnh được điền sẵn một link picsum để đỡ phải gõ. Sửa thì router truyền object Cafe qua state.extra, form điền lại tên, địa chỉ, mô tả, URL và danh mục.",
            " Ô nào bỏ trống thì validator báo “Nhập tên quán”, “Nhập địa chỉ”… Danh mục là Dropdown, em bỏ mục “Tất cả” vì đó chỉ là bộ lọc ở trang chủ, không phải loại quán. Bấm Tạo quán hoặc Lưu thay đổi xong thì pop về trang trước.",
        ],
        "form.png",
        "Hình 4. Form thêm quán, URL ảnh được điền sẵn",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, Form, ListView, TextFormField, DropdownButtonFormField, FilledButton.icon.")),
            ("line", ("Widget đặc biệt: ", "Không. Form.validate() trước khi ghi.")),
            ("lib", ("go_router", "nhận state.extra as Cafe?; lưu xong thì context.pop().")),
            ("lib", ("provider", "CafeProvider.saveCafe: id null thì insert, có id thì update.")),
            ("lib", ("flutter_local_notifications", "nếu bật thông báo thì báo “Đã thêm quán mới” hoặc “Đã cập nhật quán”.")),
            ("line", ("Quản lý trạng thái: ", "TextEditingController và cờ _saving trong StatefulWidget, để không bấm lưu hai lần. Danh sách quán sau khi lưu do provider load lại.")),
            ("line", ("Đọc/lưu dữ liệu: ", "INSERT hoặc UPDATE bảng cafes. Lúc insert em bỏ key id để SQLite tự tăng.")),
        ],
    )

    doc.add_heading("Chức năng 5. Điều hướng go_router", level=1)
    rich(
        doc,
        [
            "Toàn bộ route nằm trong lib/router/app_router.dart, hàm createAppRouter(). initialLocation là /splash. Em khai báo:",
        ],
        indent=True,
    )
    bullet(doc, "/splash")
    bullet(doc, "StatefulShellRoute.indexedStack với 4 nhánh: /home, /favorites, /reviews, /settings")
    bullet(doc, "/search (đọc queryParameters['q'] nếu có)")
    bullet(doc, "/cafe/:id")
    bullet(doc, "/cafe-form (extra là Cafe? khi sửa)")
    para(
        doc,
        "Shell dùng indexedStack nên chuyển tab không tạo lại màn hình, danh sách không bị cuộn lên đầu. Mỗi trang bọc CustomTransitionPage: FadeTransition cộng SlideTransition, lệch bắt đầu khoảng (0.04, 0.06), curve easeOutCubic. Không dùng hiệu ứng trượt full màn hình vì nhìn hơi nặng trên emulator.",
        indent=True,
    )
    para(
        doc,
        "Khi người dùng chọn một quán, ứng dụng truyền id của quán qua pathParameters để mở đúng trang chi tiết. Đó là chỗ /cafe/:id ở Hình 3. Ô tìm kiếm thì truyền chuỗi qua query, form sửa quán truyền cả object Cafe qua extra chứ không nhét hết field lên URL.",
        indent=True,
    )
    para(
        doc,
        "Trên điện thoại shell hiện NavigationBar (nhìn thấy ở Hình 2). Bề rộng từ 800 trở lên thì ShellScaffold đổi sang NavigationRail. Ảnh dưới lấy từ bộ kiểm thử Flutter ở kích thước màn hình rộng.",
        indent=True,
    )
    para(doc, "Ảnh chức năng/giao diện:", bold=True, space_after=2)
    picture(doc, "rail.png", "Hình 5. Shell trên màn rộng: NavigationRail bên trái, nội dung bên phải", 15.2)
    para(doc, "Chi tiết cài đặt:", bold=True, space_after=2)
    label_line(doc, "Widget sử dụng: ", "StatefulShellRoute, GoRoute, CustomTransitionPage, FadeTransition, SlideTransition. Vỏ tab là ShellScaffold (NavigationBar hoặc NavigationRail).")
    label_line(doc, "Widget đặc biệt: ", "StatefulNavigationShell giữ currentIndex của tab.")
    bullet(doc, "khai báo route, pageBuilder và chỗ truyền/nhận pathParameters, queryParameters, extra.", bold_prefix="go_router: ")
    label_line(doc, "Quản lý trạng thái: ", "Router không giữ dữ liệu quán. Dữ liệu vẫn ở Provider. Shell chỉ nhớ tab đang đứng.")
    label_line(doc, "Đọc/lưu dữ liệu: ", "Không ghi database. Chỉ mang id, chuỗi tìm kiếm hoặc object Cafe sang màn sau.")

    doc.add_heading("Chức năng 6. SQLite", level=1)
    para(
        doc,
        "Tầng này không có màn hình riêng. Quán seed xong hiện ở Trang chủ (Hình 2). Em tách 3 file: database_helper.dart, cafe_repository.dart, models cafe.dart và review.dart.",
        indent=True,
    )
    para(
        doc,
        "DatabaseHelper là singleton. Lần đầu mở thì getDatabasesPath() ghép với tên file cafe_spot.db, version 1. onCreate tạo hai bảng rồi seed The Coffee House, Cộng Cà Phê, Highland Coffee và Garden Beans. Hai quán The Coffee House và Garden Beans được gắn is_favorite = 1 để màn Yêu thích của bạn Vương có dữ liệu sẵn.",
        indent=True,
    )
    para(doc, "Cấu trúc bảng (đúng cột trong CREATE TABLE, em không thêm cột cho có):", space_after=4)
    add_table(
        doc,
        ["Bảng", "Cột", "Ghi chú ngắn"],
        [
            ["cafes", "id", "INTEGER, khóa chính, tự tăng"],
            ["cafes", "name, address, description, image_url, category", "TEXT, NOT NULL"],
            ["cafes", "rating", "REAL, mặc định 0. Repository ghi lại bằng điểm trung bình review."],
            ["cafes", "is_favorite", "INTEGER, 0 hoặc 1"],
            ["cafes", "created_at", "TEXT, chuỗi ISO-8601"],
            ["reviews", "id", "INTEGER, khóa chính, tự tăng"],
            ["reviews", "cafe_id", "INTEGER, khóa ngoại tới cafes(id), ON DELETE CASCADE"],
            ["reviews", "author, content", "TEXT. author lấy từ tên hiển thị trong Cài đặt."],
            ["reviews", "rating", "REAL"],
            ["reviews", "created_at", "TEXT, ISO-8601"],
        ],
        [3.2, 7.4, 5.8],
    )
    para(doc, "Vài câu query em dùng thật trong CafeRepository:", space_after=3)
    bullet(doc, "danh sách trang chủ, có thể thêm LIKE tên/địa chỉ/mô tả và category = ?.")
    bullet(doc, "yêu thích: WHERE is_favorite = 1, xếp theo tên.")
    bullet(doc, "sau khi thêm hoặc xóa review: SELECT AVG(rating) FROM reviews WHERE cafe_id = ?, rồi UPDATE cafes.rating.")
    para(doc, "Chi tiết cài đặt:", bold=True, space_after=2)
    label_line(doc, "Widget sử dụng: ", "Không có UI riêng.")
    label_line(doc, "Widget đặc biệt: ", "Không.")
    bullet(doc, "mở database, chạy CREATE TABLE và seed.", bold_prefix="sqflite: ")
    bullet(doc, "ghép đường dẫn file cafe_spot.db.", bold_prefix="path: ")
    label_line(doc, "Quản lý trạng thái: ", "Repository không gọi notifyListeners. CafeProvider gọi repository xong thì tự báo UI.")
    label_line(doc, "Đọc/lưu dữ liệu: ", "File cafe_spot.db trên máy. Xóa quán thì em xóa review của quán đó trước, rồi mới xóa dòng cafes.")

    para(
        doc,
        "Phần việc còn lại trong repo (Yêu thích, Đánh giá của tôi, Tìm kiếm, Cài đặt, notification, NavigationRail) là của bạn Nguyễn Quốc Vương. Lịch sử commit của cả hai nằm trên link GitHub ở đầu báo cáo.",
        indent=True,
        space_before=8,
    )
    return doc


def build_vuong():
    doc = Document()
    style_doc(doc)
    header_footer(doc, "DC24V7X414", "Nguyễn Quốc Vương")
    cover(
        doc,
        "DC24V7X414",
        "Nguyễn Quốc Vương",
        [
            "Trong dự án nhóm gồm 2 thành viên, em được phân công phát triển các chức năng: (1) Yêu thích, (2) Đánh giá của tôi, (3) Tìm kiếm, (4) Cài đặt, (5) thông báo cục bộ, (6) giao diện responsive và shell điều hướng. Bạn Lưu Minh Thông làm Splash, Trang chủ, chi tiết quán, form thêm/sửa, go_router và SQLite.",
            "Em không tạo database mới. Quán và review em đọc/ghi qua CafeProvider mà bạn Thông đã nối xuống CafeRepository. Phần em tự giữ state là cài đặt người dùng, lưu bằng SharedPreferences.",
        ],
    )

    doc.add_heading("Bảng em đọc, không phải bảng em tạo", level=1)
    para(
        doc,
        "Schema do bạn Thông viết trong DatabaseHelper. Em ghi lại các cột mà màn của em thực sự dùng, để lúc vấn đáp không bị lệch với code:",
        indent=True,
    )
    add_table(
        doc,
        ["Bảng", "Cột em dùng", "Dùng ở đâu"],
        [
            ["cafes", "id, name, address, image_url, rating, category, is_favorite", "Yêu thích, kết quả tìm kiếm"],
            ["reviews", "id, cafe_id, author, content, rating, created_at", "Đánh giá của tôi"],
        ],
        [3.0, 8.2, 5.2],
    )
    para(
        doc,
        "Ngoài ra cafes còn có description và created_at. Ô tìm kiếm của em có LIKE cả description, còn created_at em không vẽ ra màn Yêu thích. is_favorite lưu 0/1, không phải boolean của SQLite.",
        indent=True,
    )

    function_block(
        doc,
        "Chức năng 1. Yêu thích",
        [
            "Tab Yêu thích chỉ hiện quán đang được đánh dấu tim. Bấm thẻ thì mở chi tiết bằng context.push('/cafe/${cafe.id}'), tức là truyền id trên URL, trang chi tiết của bạn Thông nhận lại bằng pathParameters. Bấm tim một lần nữa thì gọi toggleFavorite, quán biến mất khỏi lưới này ngay vì provider load lại.",
            " Nếu chưa tim quán nào, màn hiện câu “Chưa có quán yêu thích. Nhấn trái tim ở Trang chủ.” Lúc em chụp thì đang có Garden Beans và The Coffee House, đúng hai dòng seed có is_favorite = 1.",
        ],
        "favorites.png",
        "Hình 1. Tab Yêu thích, hai quán đang được tim",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, LayoutBuilder, GridView.builder, CafeCard.")),
            ("line", ("Widget đặc biệt: ", "CafeCard dùng chung với Trang chủ. Số cột vẫn theo gridCountForWidth.")),
            ("lib", ("provider", "context.watch CafeProvider để lấy favorites và gọi toggleFavorite.")),
            ("lib", ("go_router", "push sang /cafe/:id khi bấm một quán.")),
            ("line", ("Quản lý trạng thái: ", "Màn này StatelessWidget. Danh sách nằm ở CafeProvider.favorites, không copy ra state riêng.")),
            ("line", ("Đọc/lưu dữ liệu: ", "Repository chạy query bảng cafes với WHERE is_favorite = 1, orderBy name ASC. Bấm tim thì UPDATE cột is_favorite.")),
        ],
    )

    function_block(
        doc,
        "Chức năng 2. Đánh giá của tôi",
        [
            "Tab này liệt kê mọi review trong máy, review mới ở trên. Mỗi thẻ có tên người viết, hàng sao, nội dung và giờ. Tên người viết không gõ ở màn này. Lúc gửi review bên trang chi tiết, author lấy từ displayName trong Cài đặt. Mặc định là “Sinh viên CT484”.",
            " Nút mở quán đẩy /cafe/${review.cafeId}. Nút thùng rác gọi removeReview, repository xóa dòng reviews rồi tính lại điểm trung bình của quán. Giờ em không format tay: DateFormat('dd/MM/yyyy HH:mm') của intl. Ảnh dưới là review em gửi cho The Coffee House lúc test.",
        ],
        "reviews.png",
        "Hình 2. Đánh giá của tôi, ngày giờ do intl format",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, ListView.separated, Card, ListTile, IconButton.")),
            ("line", ("Widget đặc biệt: ", "RatingStars size 16, chỉ để xem, không cho sửa sao ở màn này.")),
            ("lib", ("provider", "CafeProvider.myReviews và removeReview.")),
            ("lib", ("go_router", "mở lại đúng quán bằng id lưu trong review.cafeId.")),
            ("lib", ("intl", "định dạng created_at cho dễ đọc. Không có thư viện này thì em phải tự cắt chuỗi ISO.")),
            ("line", ("Quản lý trạng thái: ", "Watch provider. Xóa một review thì provider load lại cả list, UI tự mất dòng đó.")),
            ("line", ("Đọc/lưu dữ liệu: ", "SELECT trên bảng reviews, orderBy created_at DESC. Xóa theo id, rồi AVG(rating) ghi ngược vào cafes.rating.")),
        ],
    )

    function_block(
        doc,
        "Chức năng 3. Tìm kiếm",
        [
            "Nút kính lúp ở Trang chủ mở /search. Ô nhập được autofocus. Mỗi lần gõ, em gọi CafeProvider.setFilter(query: value), provider load lại danh sách. Repository tìm bằng LIKE trên name, address và description, không phân biệt mình đang đứng ở tab nào.",
            " Ảnh em chụp khi gõ “Coffee”. Ra hai quán có chữ đó trong tên: The Coffee House và Highland Coffee. Bấm một dòng thì cũng push /cafe/:id. Router có nhận thêm ?q= trên URL (bạn Thông khai báo trong app_router), SearchScreen nhận initialQuery và điền vào ô nếu có.",
        ],
        "search.png",
        "Hình 3. Kết quả tìm kiếm với từ khóa “Coffee”",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, TextField, ListView.separated, ListTile, CircleAvatar, Divider.")),
            ("line", ("Widget đặc biệt: ", "RatingStars size 14 đặt ở trailing của mỗi dòng. Ảnh đại diện là NetworkImage từ image_url.")),
            ("lib", ("provider", "setFilter(query:) và đọc provider.cafes.")),
            ("lib", ("go_router", "màn được mở bằng push('/search'); bấm kết quả thì push('/cafe/${id}').")),
            ("line", ("Quản lý trạng thái: ", "TextEditingController cục bộ cho ô nhập. Chuỗi lọc thì để trong CafeProvider.query để repository dùng lại.")),
            ("line", ("Đọc/lưu dữ liệu: ", "Không ghi thêm bảng. Query dạng name LIKE ? OR address LIKE ? OR description LIKE ?, tham số là %từ_khóa%.")),
        ],
    )

    function_block(
        doc,
        "Chức năng 4. Cài đặt",
        [
            "Màn Cài đặt em giữ những thứ không thuộc bảng quán: tên hiển thị khi đánh giá, chế độ tối, bật/tắt thông báo. Bấm Lưu tên thì ghi display_name. Công tắc chế độ tối đổi theme của cả MaterialApp vì main.dart đang watch SettingsProvider.themeMode.",
            " Ba giá trị này em không bỏ vào SQLite. SharedPreferences đủ dùng và mở nhanh lúc splash. Key em đặt là dark_mode, notifications_enabled và display_name. Tên để trống thì em trả về “Sinh viên CT484”, tránh review không có author.",
        ],
        "settings.png",
        "Hình 4. Cài đặt: tên hiển thị, chế độ tối, thông báo",
        6.3,
        [
            ("line", ("Widget sử dụng: ", "Scaffold, AppBar, ListView, TextField, FilledButton, SwitchListTile, OutlinedButton.icon, ListTile, Divider.")),
            ("line", ("Widget đặc biệt: ", "SwitchListTile cho hai công tắc. ResponsiveCenter bọc nội dung, màn rộng không bị giãn hết chiều ngang.")),
            ("lib", ("provider", "SettingsProvider extends ChangeNotifier, màn watch provider này.")),
            ("lib", ("shared_preferences", "đọc/ghi 3 key ở trên. load() được splash gọi trước khi vào home.")),
            ("lib", ("flutter_local_notifications", "nút “Gửi thông báo thử” gọi NotificationService khi công tắc đang bật. Tắt công tắc thì nút disable.")),
            ("line", ("Quản lý trạng thái: ", "SettingsProvider. TextField giữ controller riêng, chỉ ghi tên khi bấm Lưu tên hoặc submit.")),
            ("line", ("Đọc/lưu dữ liệu: ", "SharedPreferences, không đụng bảng cafes/reviews. Tên này về sau được trang chi tiết lấy làm author của review.")),
        ],
    )

    doc.add_heading("Chức năng 5. Thông báo cục bộ", level=1)
    para(
        doc,
        "Em dùng flutter_local_notifications, không dùng FCM vì app không có server. NotificationService là singleton. main() gọi init() trước runApp: icon launcher, xin quyền POST_NOTIFICATIONS trên Android, khai báo kênh cafe_spot_channel tên hiển thị “CafeSpot” khi gửi thông báo.",
        indent=True,
    )
    para(
        doc,
        "Có ba chỗ gọi showCafeReminder. Một là nút thử trong Cài đặt, title “CafeSpot”, body “Đây là thông báo thử nghiệm từ ứng dụng.” Hai là sau khi thêm hoặc sửa quán. Ba là sau khi gửi review. Hai chỗ sau chỉ chạy khi SettingsProvider.notificationsEnabled đang true. Em không lưu nội dung thông báo vào database, gửi xong là xong.",
        indent=True,
    )
    para(
        doc,
        "Ảnh dưới là khay thông báo của máy sau khi em bấm nút thử. Dòng CafeSpot nằm trên cùng.",
        indent=True,
    )
    para(doc, "Ảnh chức năng/giao diện:", bold=True, space_after=2)
    picture(doc, "notify.png", "Hình 5. Thông báo thử của CafeSpot trên thanh thông báo Android", 6.3)
    para(doc, "Chi tiết cài đặt:", bold=True, space_after=2)
    label_line(doc, "Widget sử dụng: ", "Không có màn riêng. Gọi từ nút ở Cài đặt, và từ form / trang chi tiết sau khi ghi dữ liệu thành công.")
    label_line(doc, "Widget đặc biệt: ", "Không.")
    bullet(doc, "khởi tạo plugin, tạo channel, show() với AndroidNotificationDetails importance mặc định.", bold_prefix="flutter_local_notifications: ")
    bullet(doc, "công tắc notifications_enabled quyết định có được gọi show hay không.", bold_prefix="provider + shared_preferences: ")
    label_line(doc, "Quản lý trạng thái: ", "Không có list thông báo trong RAM. Chỉ một cờ bool trong SettingsProvider.")
    label_line(doc, "Đọc/lưu dữ liệu: ", "Không ghi SQLite. ID thông báo lấy từ millisecondsSinceEpoch ~/ 1000, tức là các thông báo gửi cùng giây có thể dùng chung ID.")

    doc.add_heading("Chức năng 6. Responsive và shell", level=1)
    para(
        doc,
        "Bốn tab Trang chủ, Yêu thích, Đánh giá, Cài đặt nằm trong StatefulShellRoute nên đổi tab không mất trang đang mở. Phần vỏ em làm trong ShellScaffold. Em lấy MediaQuery.sizeOf(context).width. Dưới 800 thì NavigationBar dưới đáy (các ảnh điện thoại ở trên). Từ 800 trở lên thì NavigationRail bên trái, nhãn hiện đủ chữ.",
        indent=True,
    )
    para(
        doc,
        "Nội dung từng màn em bọc ResponsiveCenter, maxWidth 900. Màn hình rất rộng thì hai bên chừa trống, chữ không bị kéo một hàng dài. Lưới quán tăng số cột theo bề rộng nhờ gridCountForWidth. Ảnh dưới lấy từ bộ kiểm thử Flutter ở kích thước màn hình rộng. Tab Cài đặt đang mở và NavigationRail nằm bên trái.",
        indent=True,
    )
    para(doc, "Ảnh chức năng/giao diện:", bold=True, space_after=2)
    picture(doc, "rail.png", "Hình 6. Màn rộng: NavigationRail thay cho NavigationBar", 15.2)
    para(doc, "Chi tiết cài đặt:", bold=True, space_after=2)
    label_line(doc, "Widget sử dụng: ", "NavigationBar, NavigationRail, NavigationDestination, LayoutBuilder, VerticalDivider.")
    label_line(doc, "Widget đặc biệt: ", "ResponsiveCenter và gridCountForWidth trong lib/widgets/responsive_center.dart.")
    bullet(doc, "StatefulNavigationShell.goBranch khi chọn tab. initialLocation = true nếu bấm lại đúng tab đang đứng.", bold_prefix="go_router: ")
    label_line(doc, "Quản lý trạng thái: ", "Index tab là navigationShell.currentIndex, em không tự lưu thêm một biến selected.")
    label_line(doc, "Đọc/lưu dữ liệu: ", "Không. Đây chỉ là cách xếp widget theo chiều rộng.")

    para(
        doc,
        "Splash, Trang chủ, chi tiết quán, form và file SQLite là phần của bạn Lưu Minh Thông. Em có gọi CafeProvider và có push /cafe/:id, nhưng không sửa schema. Commit của cả nhóm xem trên GitHub ghi ở trang đầu.",
        indent=True,
        space_before=8,
    )
    return doc


def main():
    thong = OUT / "Baocao_BK24V7X703_LuuMinhThong.docx"
    vuong = OUT / "Baocao_DC24V7X414_NguyenQuocVuong.docx"
    build_thong().save(thong)
    build_vuong().save(vuong)
    print("saved", thong)
    print("saved", vuong)
    for src in (thong, vuong):
        dst = ROOT / src.name
        try:
            dst.write_bytes(src.read_bytes())
            print("copied", dst)
        except PermissionError:
            print("locked", dst)


if __name__ == "__main__":
    main()
