// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {
    struct NguoiDongThue {
        string tenNguoi;     // Tên người nộp thuế
        uint idNguoi;       // Số CCCD
        address diaChiVi;   // Địa chỉ ví
        bool dangHoatDong;  // Trạng thái hợp lệ của người đóng thuế
        uint256 tieuMucThue; // Loại thuế
        uint mucThue;       // Tỉ lệ thuế
        uint soTienThue;    // Số tiền thuế
        bool daThanhToan;   // Đã trả xong thuế chưa
        uint duocMienGiam;  // Chính sách miễn giảm
        uint thuNhap;       // Thu nhập
        string diaChi;      // Địa chỉ của người đóng thuế
        uint dieuKien;      // Loại giảm
    }

    // Lưu danh sách địa chỉ ví theo idNguoi
    mapping(uint => address[]) public danhSachVi;

    // Lưu thông tin thuế theo địa chỉ ví
    mapping(address => NguoiDongThue) public danhSachThue;

    // Địa chỉ của admin (người triển khai hợp đồng)
    address public admin;
    uint  tkAdmin;
    // Sự kiện thông báo khi hồ sơ được cấp
    event HoSoThueCapPhat(
        uint idNguoi, 
        address indexed diaChiVi, 
        string tenNguoi, 
        bool dangHoatDong, 
        uint tieuMucThue, 
        uint mucThue, 
        uint soTienThue, 
        uint duocMienGiam, 
        string diaChi, 
        uint thuNhap
    );

    // Chỉ định quyền admin cho người triển khai hợp đồng
    modifier chiAdmin() {
        require(msg.sender == admin, unicode"Chỉ admin mới có quyền thực hiện.");
        _;
    }

    // Constructor: Khởi tạo admin là người triển khai hợp đồng
    constructor() {
        admin = msg.sender;
    }

    // Cấp hồ sơ thuế
    function capHoSoThue(
        uint _idNguoi,
        address _diaChiVi,
        string memory _diaChi,
        uint256 _tieuMucThue, 
        uint256 _thuNhap, 
        uint _dieuKien,
        string memory _tenNguoi
    ) public chiAdmin {
        require(danhSachThue[_diaChiVi].dangHoatDong == false, unicode"Hồ sơ đã tồn tại cho địa chỉ ví này.");

        // Tạo hồ sơ thuế mới
        danhSachThue[_diaChiVi] = NguoiDongThue({
            tenNguoi: _tenNguoi,
            idNguoi: _idNguoi,
            diaChiVi: _diaChiVi,
            thuNhap: _thuNhap,
            diaChi: _diaChi,
            dangHoatDong: true,
            tieuMucThue: _tieuMucThue,
            mucThue: 0,
            soTienThue: 0,
            daThanhToan: false,
            duocMienGiam: 0,
            dieuKien: _dieuKien
        });

        // Thêm địa chỉ ví vào danh sách của idNguoi
        danhSachVi[_idNguoi].push(_diaChiVi);
        emit HoSoThueCapPhat(
            _idNguoi,
            _diaChiVi,
            _tenNguoi,
            true,
            _tieuMucThue,
            0,
            0,
            0,
            _diaChi,
            _thuNhap
        );
    }
    // Hủy bỏ hồ sơ thuế
    function huyHoSoThue(address _diaChiVi) public chiAdmin {
        require(danhSachThue[_diaChiVi].dangHoatDong, unicode"Hồ sơ không hợp lệ hoặc không tồn tại.");
        danhSachThue[_diaChiVi].dangHoatDong = false;
    }

    // Xem mức thuế
    function tinhThue(address _diaChiVi) public {
        if (danhSachThue[_diaChiVi].tieuMucThue == 1004 || danhSachThue[_diaChiVi].tieuMucThue == 1005) {
            danhSachThue[_diaChiVi].mucThue = 5;
        } else if (danhSachThue[_diaChiVi].tieuMucThue == 1006) {
            danhSachThue[_diaChiVi].mucThue = 10;
        } else if (danhSachThue[_diaChiVi].tieuMucThue == 1007) {
            danhSachThue[_diaChiVi].mucThue = 20;
        } else if (danhSachThue[_diaChiVi].tieuMucThue == 1001 || danhSachThue[_diaChiVi].tieuMucThue == 1003) {
            if (danhSachThue[_diaChiVi].thuNhap <= 11000000) {
                danhSachThue[_diaChiVi].mucThue = 0;
                danhSachThue[_diaChiVi].daThanhToan = true;
            } else if (danhSachThue[_diaChiVi].thuNhap > 11000000 && danhSachThue[_diaChiVi].thuNhap <= 60000000) {
                danhSachThue[_diaChiVi].mucThue = 5;
            } else if (danhSachThue[_diaChiVi].thuNhap <= 120000000) {
                danhSachThue[_diaChiVi].mucThue = 10;
            } else if (danhSachThue[_diaChiVi].thuNhap <= 216000000) {
                danhSachThue[_diaChiVi].mucThue = 15;
            } else if (danhSachThue[_diaChiVi].thuNhap < 384000000) {
                danhSachThue[_diaChiVi].mucThue = 20;
            } else if (danhSachThue[_diaChiVi].thuNhap < 624000000) {
                danhSachThue[_diaChiVi].mucThue = 25;
            } else if (danhSachThue[_diaChiVi].thuNhap < 960000000) {
                danhSachThue[_diaChiVi].mucThue = 30;
            } else {
                danhSachThue[_diaChiVi].mucThue = 35;
            }
        } else {
            danhSachThue[_diaChiVi].mucThue = 0;
            danhSachThue[_diaChiVi].daThanhToan = true;
        }

        // Xem Miễn Giảm
        if (danhSachThue[_diaChiVi].dieuKien == 1) {
            danhSachThue[_diaChiVi].duocMienGiam = 100;
            danhSachThue[_diaChiVi].daThanhToan = true;
        } else if (danhSachThue[_diaChiVi].dieuKien == 2) {
            danhSachThue[_diaChiVi].duocMienGiam = 50;
        } else {
            danhSachThue[_diaChiVi].duocMienGiam = 0;
        }
        
        // Tính Thuế
        danhSachThue[_diaChiVi].soTienThue = (danhSachThue[_diaChiVi].thuNhap - danhSachThue[_diaChiVi].thuNhap * danhSachThue[_diaChiVi].duocMienGiam / 100)
         * danhSachThue[_diaChiVi].mucThue / 100;
    }

    // Thanh toán
    function thanhToan (address _diaChiVi) public {
        require(danhSachThue[_diaChiVi].dangHoatDong, unicode"Hồ sơ không hợp lệ hoặc đã bị hủy.");
        tkAdmin += danhSachThue[_diaChiVi].soTienThue;
        danhSachThue[_diaChiVi].daThanhToan = true;
    }
}
