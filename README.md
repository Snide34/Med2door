Project Title: Med2Door
Med2Door is a full-stack pharmaceutical e-commerce platform designed to bridge the gap between complex medical databases and end-user accessibility. It manages an inventory of 1,085 medicines with real-time stock and prescription validation.

1. Technical Stack (The "How")
Frontend: Built using Flutter for cross-platform efficiency and pixel-perfect UI rendering based on modern healthcare design principles.

Backend-as-a-Service (BaaS): Supabase (PostgreSQL) serves as the relational engine, handling structured data for medicines, categories, and users.

Database Management: We implemented a custom schema to handle medical-specific fields like composition (drug content), manufacturer origin, and product variants (e.g., Tablets vs. Syrups).

Storage Logic: Supabase Storage is used to host user-uploaded prescriptions, ensuring medical compliance for restricted drugs.

2. Core Features & Architecture
Dynamic Data Fetching: The app connects to a product table to display real-time pricing and medical details.

Prescription-Driven Workflow: Using a boolean logic gate (is_prescripti), the app detects restricted medicines and automatically routes the user to a Prescription Order module before checkout.

Medical Transparency: Users can view the chemical composition and generic name of every product, ensuring informed purchases.

Scalable Search: The architecture supports filtering by disease category (e.g., Acne, ADHD) across the entire 1,000+ item catalog.

3. Performance Engineering (Solving the "Lag")
To ensure a professional-grade experience, the project addresses two major mobile challenges:

Memory Management: Instead of loading the 100MB+ dataset at once, the app utilizes Pagination to load records in small, performant batches.

Network Optimization: We implemented Image Caching (CachedNetworkImage) to store medicine photos locally, reducing data consumption and eliminating scrolling lag
