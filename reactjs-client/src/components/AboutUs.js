import React from "react";
import "./AboutUs.css";

import logo from "../assets/logo.png";
import kitchen from "../assets/kitchen.png";       // ✅ PNG
import chef from "../assets/chef-antonio.png";     // ✅ PNG
import maria from "../assets/maria-lopez.png";     // ✅ PNG

function AboutUs() {

  // =========================================================
  // ABOUT US PAGE STRUCTURE
  // - Logo replaces title
  // - Restaurant description
  // - Image section
  // - Quote
  // - Team (side by side)
  // =========================================================

  return (
    <div className="about-page">

      {/* =====================================================
          MAIN CONTENT (TEXT + IMAGE SIDE BY SIDE)
      ====================================================== */}
      <div className="about-content">

        {/* LEFT TEXT SECTION */}
        <div className="about-text">

            <h2 className="about-subtitle">Our restaurant</h2>

            {/* ✅ LOGO INSERTED HERE */}
            <div className="about-inline-logo">
                <img src={logo} alt="Café Fausse logo" />
            </div>

            <p>
                Founded in 2010 by Chef Antonio Rossi and restaurateur Maria Lopez,
                Café Fausse blends traditional Italian flavors with modern culinary
                innovation. Our mission is to provide an unforgettable dining experience
                that reflects both quality and creativity.
            </p>

        </div>

        {/* RIGHT IMAGE */}
        <div className="about-image">
          <img src={kitchen} alt="Restaurant kitchen" />
        </div>
      </div>

      {/* =====================================================
          QUOTE SECTION (SCRIPT STYLE)
      ====================================================== */}
      <div className="about-quote">
        Café Fausse is dedicated to delivering an unforgettable dining
        experience, combining exceptional cuisine with carefully selected,
        locally sourced ingredients to ensure every dish is both refined
        and thoughtfully crafted.
      </div>

      {/* =====================================================
          ✅ TEAM SECTION (SIDE-BY-SIDE)
      ====================================================== */}
      <div className="team-section">

        <div className="team-grid">

          {/* ---------- CHEF ---------- */}
          <div className="team-card">

            <div className="team-image chef">
              <img src={chef} alt="Chef Antonio Rossi" />
            </div>

            <h3>Chef Antonio Rossi</h3>

            <p>
              Chef Antonio Rossi, co-founder of Café Fausse, is the culinary visionary
              behind its refined menu, blending traditional Italian flavors with
              modern innovation using the finest locally sourced ingredients.
            </p>

          </div>

          {/* ---------- MARIA ---------- */}
          <div className="team-card">

            <div className="team-image maria">
              <img src={maria} alt="Maria Lopez" />
            </div>

            <h3>Restaurateur Maria Lopez</h3>

            <p>
              Maria Lopez, co-founder and restaurateur of Café Fausse, brings a passion
              for hospitality and design, shaping an elegant dining experience that
              complements the restaurant’s culinary excellence.
            </p>

          </div>

        </div>
      </div>

    </div>
  );
}

export default AboutUs;
