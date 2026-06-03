import { Routes, Route } from "react-router-dom";
import { useState, useEffect, useRef } from "react";

import Home from "./components/Home";
import Menu from "./components/Menu";
import Reservation from "./components/Reservation";
import AboutUs from "./components/AboutUs";
import Gallery from "./components/Gallery";
import Admin from "./components/Admin";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";

import "./App.css";

function App() {
  const [showNewsletter, setShowNewsletter] = useState(false);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    phone: "",
  });
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState("");
  
  // Track if we've already shown the popup in this session
  const hasShownInSession = useRef(false);

  // Check if user has already seen the popup (persistent across sessions)
  useEffect(() => {
    const hasSeenNewsletter = localStorage.getItem('newsletterShown');
    
    // Only show if never seen before AND not shown in this session yet
    if (!hasSeenNewsletter && !hasShownInSession.current) {
      const timer = setTimeout(() => {
        setShowNewsletter(true);
        hasShownInSession.current = true;
      }, 5000);
      return () => clearTimeout(timer);
    }
  }, []);

  const markNewsletterShown = () => {
    localStorage.setItem('newsletterShown', 'true');
    hasShownInSession.current = true;
  };

  const openNewsletter = () => {
    // Always allow footer to open popup (user clicked it intentionally)
    setShowNewsletter(true);
    setError("");
    setSubmitted(false);
  };

  const closeNewsletter = () => {
    setShowNewsletter(false);
    // Mark as shown so auto-popup won't show again
    localStorage.setItem('newsletterShown', 'true');
    setFormData({ firstName: "", lastName: "", email: "", phone: "" });
    setSubmitted(false);
    setError("");
  };

  function handleChange(e) {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");

    try {
      const response = await fetch("http://localhost:5001/api/newsletter-signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      const result = await response.json();

      if (!response.ok || !result.success) {
        throw new Error(result.error || "Failed to sign up");
      }

      setSubmitted(true);
      markNewsletterShown();
    } catch (err) {
      setError(err.message || "Failed to sign up. Please try again.");
    }
  }

  return (
    <>
      <Navbar />

      <Routes>
        {/* ✅ Pass control to Home */}
        <Route
          path="/"
          element={
            <Home
              showNewsletter={showNewsletter}
              setShowNewsletter={setShowNewsletter}
            />
          }
        />

        <Route path="/menu" element={<Menu />} />
        <Route path="/reservation" element={<Reservation />} />
        <Route path="/about" element={<AboutUs />} />
        <Route path="/gallery" element={<Gallery />} />
        <Route path="/admin" element={<Admin />} />
      </Routes>

      {/* ✅ Footer can now trigger popup */}
      <Footer openNewsletter={openNewsletter} />

      {/* =====================================================
          ✅ GLOBAL NEWSLETTER POPUP
      ====================================================== */}
      {showNewsletter && (
        <div className="newsletter-overlay">
          <div className="newsletter-modal">
            {/* CLOSE BUTTON */}
            <button
              className="newsletter-close"
              onClick={closeNewsletter}
              aria-label="Close newsletter popup"
            >
              ✕
            </button>

            {/* LOGO */}
            <div className="newsletter-logo-wrap">
              <img src={require("./assets/logo.png")} alt="logo" className="newsletter-logo" />
            </div>

            {/* SUBTITLE */}
            <h4 className="newsletter-subtitle">
              {submitted ? "Thank You!" : "Sign up for our Newsletter!"}
            </h4>

            {/* SUCCESS MESSAGE */}
            {submitted && (
              <div className="newsletter-success">
                <p>You've successfully signed up for our newsletter!</p>
                <p>You'll be the first to know about special events and promotions.</p>
                <button className="newsletter-close-btn" onClick={closeNewsletter}>
                  Close
                </button>
              </div>
            )}

    {/* FORM - Only show when NOT submitted */}
    {!submitted && (
      <form className="newsletter-form" onSubmit={handleSubmit}>
        {error && <div className="newsletter-error">{error}</div>}

        <div className="newsletter-row">
          <div className="newsletter-field">
            <label>First Name*</label>
            <input
              type="text"
              name="firstName"
              value={formData.firstName}
              onChange={handleChange}
              required
            />
          </div>

          <div className="newsletter-field">
            <label>Last Name*</label>
            <input
              type="text"
              name="lastName"
              value={formData.lastName}
              onChange={handleChange}
              required
            />
          </div>
        </div>

        <div className="newsletter-field full-width">
          <label>E-mail*</label>
          <input
            type="email"
            name="email"
            value={formData.email}
            onChange={handleChange}
            required
          />
        </div>

        <div className="newsletter-field full-width">
          <label>Phone number (optional) </label>
          <input
            type="text"
            name="phone"
            value={formData.phone}
            onChange={handleChange}
          />
        </div>

        <button type="submit" className="newsletter-submit-btn">
          Sign Up
        </button>
      </form>
    )}

    {/* SUBMITTED STATE - Show as static text */}
    {submitted && (
      <div className="newsletter-submitted-info">
        <div className="newsletter-info-row">
          <label>First Name</label>
          <p className="newsletter-info-text">{formData.firstName}</p>
        </div>

        <div className="newsletter-info-row">
          <label>Last Name</label>
          <p className="newsletter-info-text">{formData.lastName}</p>
        </div>

        <div className="newsletter-info-row">
          <label>E-mail</label>
          <p className="newsletter-info-text">{formData.email}</p>
        </div>

        <div className="newsletter-info-row">
          <label>Phone Number</label>
          <p className="newsletter-info-text">{formData.phone || "Not provided"}</p>
        </div>
      </div>
    )}


            {!submitted && (
              <p className="newsletter-note">
                We respect your inbox
                <br />
                Unsubscribe anytime
              </p>
            )}
          </div>
        </div>
      )}
    </>
  );
}

export default App;
