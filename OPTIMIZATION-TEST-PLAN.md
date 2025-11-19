# Optimization Test Plan - Dezembro Vermelho 2025

## Files Modified
- `index.html` - Homepage with activity listing and filters
- `form-template.html` - Dynamic enrollment form

## Backup Files Created
- `index_backup.html`
- `form-template_backup.html`

## Optimizations Made

### index.html
1. ✅ Simplified template literals for className concatenation
2. ✅ Added early return checks in filter functions to prevent unnecessary re-renders
3. ✅ Removed redundant `dataset.date` attribute (not used)
4. ✅ Removed unnecessary comments

**Lines saved**: ~15 lines
**Performance improvement**: Prevents re-rendering when clicking same filter button

### form-template.html
1. ✅ Removed redundant `checkExistingEnrollment()` function (~35 lines)
2. ✅ Removed all console.log statements (~20 occurrences)
3. ✅ Removed duplicate localStorage check after HTML confirmation (~20 lines)
4. ✅ Removed HTML text parsing for duplicate detection (~20 lines)
5. ✅ Consolidated localStorage enrollment tracking (single source of truth)
6. ✅ Simplified error handling logic

**Lines saved**: ~120 lines
**Performance improvement**: Reduced complexity, faster execution

---

## Test Plan

### A. index.html Tests

#### Test 1: Page Load
- [ ] Page loads without errors
- [ ] Loading indicator appears initially
- [ ] Activities grid appears after data loads
- [ ] Header and footer display correctly

#### Test 2: Day Filter Functionality
- [ ] "Todos os Dias" button shows all activities
- [ ] Clicking a specific day filters activities correctly
- [ ] Active button state displays correctly
- [ ] Type filter resets to "all" when changing days
- [ ] No duplicate rendering when clicking same button twice

#### Test 3: Type Filter Functionality
- [ ] "Todos os Tipos" button shows all activities for current day
- [ ] Clicking a specific type filters activities correctly
- [ ] Active button state displays correctly
- [ ] Type buttons update based on selected day
- [ ] No duplicate rendering when clicking same button twice

#### Test 4: Activity Cards
- [ ] All activity information displays correctly (name, date, time, location, type)
- [ ] Capacity information shows correctly
- [ ] "Fazer Inscrição" button appears for available activities
- [ ] "Vagas Esgotadas" button appears for full activities
- [ ] Links to form-template.html with correct ?id= parameter

#### Test 5: API Integration
- [ ] Fetches data from n8n webhook successfully
- [ ] Handles API errors gracefully
- [ ] Displays error message if fetch fails

#### Test 6: Responsive Design
- [ ] Desktop layout works correctly
- [ ] Mobile layout adapts properly
- [ ] Filters are accessible on mobile

---

### B. form-template.html Tests

#### Test 7: Form Load
- [ ] Page loads with ?id= parameter
- [ ] Activity information displays correctly
- [ ] Form fields render properly
- [ ] Error shown if no ID parameter provided
- [ ] Error shown if activity not found

#### Test 8: Form Validation
- [ ] Name field is required
- [ ] Email field is required and validates format
- [ ] CPF field is optional
- [ ] CPF auto-formats as user types (000.000.000-00)
- [ ] LGPD checkbox is required

#### Test 9: Duplicate Detection (Pre-Submission)
- [ ] localStorage check prevents duplicate submission
- [ ] Error message displays if duplicate detected
- [ ] "Ver Outras Atividades" link works

#### Test 10: Form Submission - Success Path
- [ ] Form submits to n8n webhook
- [ ] Loading state shows during submission
- [ ] Success: Enrollment tracked in localStorage
- [ ] Success: Ticket ID stored (from response or generated)
- [ ] Success: User data stored in localStorage
- [ ] Success: Redirects to confirmation-template.html

#### Test 11: Form Submission - Error Paths
- [ ] Duplicate response (status: 'duplicate') shows error
- [ ] Full capacity response (status: 'full') shows error
- [ ] General error response (status: 'error') shows error
- [ ] Network error shows connection failure message
- [ ] Submit button re-enables after error

#### Test 12: HTML Response Handling
- [ ] HTML response from n8n is handled
- [ ] Ticket ID extracted from HTML (regex: DV25-[A-Z0-9]{7})
- [ ] Fallback ticket ID generated if not found
- [ ] Enrollment tracked only once
- [ ] Redirects to confirmation page

#### Test 13: localStorage Management
- [ ] `dv_enrollments` array stores enrollments correctly
- [ ] Enrollment key format: `email_activityid`
- [ ] Data persists across page reloads
- [ ] No duplicate entries added

---

## Critical Functionality Checklist

### Must Work 100%
1. ✅ **Day and type filtering** - Users must be able to filter activities
2. ✅ **Activity display** - All activity information must show correctly
3. ✅ **Form validation** - Required fields must be enforced
4. ✅ **Duplicate prevention** - Users cannot register twice for same activity
5. ✅ **Form submission** - Data must submit to n8n correctly
6. ✅ **Confirmation redirect** - Must redirect to confirmation page on success
7. ✅ **Error handling** - Errors must display user-friendly messages

---

## Testing Commands

### Start Local Server
```bash
cd "/Users/cpantin/Library/CloudStorage/GoogleDrive-colin@cpantin.com/My Drive/@Ministério da Saúde/OPAS 2026/sistema programacao dezembro vermelho"
python3 -m http.server 8080
```

### Access Pages
- Homepage: http://localhost:8080/index.html
- Form (example): http://localhost:8080/form-template.html?id=1

### Clear localStorage (Browser Console)
```javascript
localStorage.clear()
```

### Check localStorage (Browser Console)
```javascript
console.log(localStorage.getItem('dv_enrollments'))
```

---

## Rollback Instructions

If issues are found:

```bash
# Restore index.html
cp index_backup.html index.html

# Restore form-template.html
cp form-template_backup.html form-template.html
```

---

## Sign-off

- [ ] All index.html tests passed
- [ ] All form-template.html tests passed
- [ ] No functionality broken
- [ ] Ready for production
