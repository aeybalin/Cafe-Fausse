import React from "react";
import "./Menu.css";
import logo from "../assets/logo.png";

function Menu() {
  return (
    <div className="menu-page">

      {/* =====================================================
          LOGO
      ====================================================== */}
      <div className="menu-logo-container">
        <img src={logo} alt="Café Fausse logo" className="menu-logo" />
      </div>

      {/* =====================================================
          MAIN MENU CARD
      ====================================================== */}
      <div className="menu-card">

        {/* TITLE */}
        <h1 className="menu-title">MENU</h1>

        {/* ================= STARTERS ================= */}
        <div className="menu-section">
          <h2 className="menu-category">Starters:</h2>

          <MenuItem
            name="Bruschetta"
            description="Fresh tomatoes, basil, olive oil, and toasted baguette slices"
            price="$8.50"
          />

          <MenuItem
            name="Caesar Salad"
            description="Crisp romaine with homemade Caesar dressing"
            price="$9.00"
          />
        </div>

        {/* ================= MAIN COURSES ================= */}
        <div className="menu-section">
          <h2 className="menu-category">Main Courses:</h2>

          <MenuItem
            name="Grilled Salmon"
            description="Served with lemon butter sauce and seasonal vegetables"
            price="$22.00"
          />

          <MenuItem
            name="Ribeye Steak"
            description="12 oz prime cut with garlic mashed potatoes"
            price="$28.00"
          />

          <MenuItem
            name="Vegetable Risotto"
            description="Creamy Arborio rice with wild mushrooms"
            price="$18.00"
          />
        </div>

        {/* ================= DESSERTS ================= */}
        <div className="menu-section">
          <h2 className="menu-category">Desserts:</h2>

          <MenuItem
            name="Tiramisu"
            description="Classic Italian dessert with mascarpone"
            price="$7.50"
          />

          <MenuItem
            name="Cheesecake"
            description="Creamy cheesecake with berry compote"
            price="$7.00"
          />
        </div>

        {/* ================= BEVERAGES ================= */}
        <div className="menu-section">
          <h2 className="menu-category">Beverages:</h2>

          <MenuItem
            name="Red Wine (Glass)"
            description="A selection of Italian reds"
            price="$10.00"
          />

          <MenuItem
            name="White Wine (Glass)"
            description="Crisp and refreshing"
            price="$9.00"
          />

          <MenuItem
            name="Craft Beer"
            description="Local artisan brews"
            price="$6.00"
          />

          <MenuItem
            name="Espresso"
            description="Strong and aromatic"
            price="$3.00"
          />
        </div>

      </div> {/* ✅ END of menu-card */}

      {/* =====================================================
          ✅ NOTES SECTION (NOW OUTSIDE CARD – FIXED)
      ====================================================== */}
      <div className="menu-notes">
        <ul>
          <li>Our menu is seasonally updated</li>
          <li>
            Our staff is here to help you and can provide some pairing suggestions
          </li>
        </ul>
      </div>

    </div>
  );
}

/* =========================================================
   REUSABLE MENU ITEM COMPONENT
========================================================= */
function MenuItem({ name, description, price }) {
  return (
    <div className="menu-item">
      <div className="menu-item-header">
        <span className="item-name">{name}</span>
        <span className="dots"></span>
        <span className="price">{price}</span>
      </div>

      <p className="description">{description}</p>
    </div>
  );
}

export default Menu;