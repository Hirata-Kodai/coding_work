package com.example.chatgptBookStore.controller;

import com.example.chatgptBookStore.model.Book;
import com.example.chatgptBookStore.model.Sale;
import com.example.chatgptBookStore.service.BookService;
import com.example.chatgptBookStore.service.SaleService;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/sales")
public class SalesController {
    @Autowired
    private BookService bookService;
    @Autowired
    private SaleService saleService;

    @GetMapping("")
    public String showSales(Model model) {
        List<Sale> sales = saleService.findAll();
        model.addAttribute("sales", sales);
        return "sales";
    }

    @GetMapping("/new")
    public String newSale(Model model) {
        Sale sale = new Sale();
        List<Book> books = bookService.findAll();
        model.addAttribute("sale", sale);
        model.addAttribute("books", books);
        return "new_sales";
    }

    @PostMapping("")
    public String saveSale(@ModelAttribute("sale") Sale sale) {
        saleService.save(sale);
        return "redirect:/sales";
    }
}
