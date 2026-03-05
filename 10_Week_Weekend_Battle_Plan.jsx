import { useState } from "react";

const WEEKS = [
  {
    week: 1,
    phase: "CONTAINERS",
    title: "Docker + Your First Deployable API",
    color: "#0EA5E9",
    tagline: "Friday: Build. Saturday: Dockerise & push.",
    why: "Everything else depends on containers. You need a running app before you can orchestrate, deploy, or monitor anything.",
    friday: [
      "Have AI scaffold a FastAPI (Python) REST API with PostgreSQL — CRUD endpoints, health check, error handling",
      "Read every file AI generates. Understand the project structure, the ORM, the route handlers",
      "Run it locally, hit every endpoint with curl or Postman, verify it works",
      "Write a proper README skeleton (you'll flesh it out as the project grows)",
    ],
    saturday: [
      "Write a Dockerfile (multi-stage build: slim image, non-root user) — have AI draft it, then read each line",
      "Create docker-compose.yml: API + PostgreSQL + Redis (Redis for later use)",
      "Push your image to GitHub Container Registry (GHCR) — free, unlimited for public repos",
      "Run 'docker stats' — understand memory/CPU. Exec into the container and poke around",
      "Break it: wrong port mapping, delete the volume (watch data vanish), set memory limit too low",
    ],
    weeknights: {
      saa: "Sections 22 (Data & Analytics — finish remaining 5 lectures) + Section 23 (Machine Learning — 13 lectures). ~1hr 15min total. These are memorization-heavy, perfect for weeknights.",
      schedule: "Mon/Tue/Wed — 25 min per night. Take notes on services you haven't touched (Athena, Glue, QuickSight, SageMaker, Rekognition). Don't stress these — they're 2-3 questions on the exam max.",
    },
    cost: "💰 $0 — Docker runs locally. GHCR is free for public repos.",
    output: "GitHub repo: 'containerised-api-platform' — Dockerfile + compose + working API",
    linkedin: {
      post: "Containerised my first production-style API this weekend",
      angle: "Share your Dockerfile as a code screenshot. Explain multi-stage builds and why image size matters. End with 'Next: deploying this to real cloud infrastructure.' Short, technical, sets up the series.",
    },
  },
  {
    week: 2,
    phase: "INFRASTRUCTURE",
    title: "Terraform + AWS Networking Foundation",
    color: "#6366F1",
    tagline: "Friday: VPC from scratch. Saturday: Deploy your API to EC2.",
    why: "VPC is the hardest SAA topic AND the most asked in interviews. Building it with Terraform while studying Section 27 will burn it into your brain permanently.",
    friday: [
      "Terraform init: create an S3 backend + DynamoDB lock table (do this once, use forever)",
      "Provision a VPC: 2 public subnets, 2 private subnets across 2 AZs, Internet Gateway, NAT Gateway",
      "Security groups: one for ALB (80/443 inbound), one for EC2 (only from ALB SG), one for RDS (only from EC2 SG)",
      "Have AI generate the Terraform — but YOU draw the architecture diagram first on paper, then verify the code matches",
    ],
    saturday: [
      "Deploy your Week 1 API on a t3.micro EC2 instance in the private subnet (free tier eligible)",
      "Put an ALB in front, configure health checks, attach your domain via Route 53",
      "Deploy RDS PostgreSQL (db.t3.micro, free tier) in private subnet — connect your API to it",
      "Run 'terraform destroy' at end of day. Rebuild Monday evening in 5 minutes. Feel the power of IaC.",
      "Break it: open security group to 0.0.0.0/0, try to SSH into private subnet without bastion, misconfigure NAT",
    ],
    weeknights: {
      saa: "Section 27 (VPC) — this is the big one: 38 lectures, 2hr 38min. Split across the full week.",
      schedule: "Mon-Fri — 30 min per night. You'll be studying VPC theory while having JUST built one. Subnets, NACLs, route tables, NAT vs IGW, VPC peering, endpoints — all of it will click because you've seen the Terraform.",
    },
    cost: "💰 ~$2-5 if you tear down Saturday night. NAT Gateway is $0.045/hr — the main cost. Destroy when not using. RDS free tier: 750 hrs/month. ALB: ~$0.60/day.",
    output: "GitHub repo: 'aws-terraform-infra' — VPC modules, variables, architecture diagram",
    linkedin: {
      post: "Built my entire AWS network with zero console clicks — here's the architecture",
      angle: "Share your hand-drawn or Excalidraw architecture diagram. Explain WHY public vs private subnets, WHY the security group chain. This is the kind of content DevOps leads share.",
    },
  },
  {
    week: 3,
    phase: "INFRASTRUCTURE",
    title: "Kubernetes on k3s (Cost-Effective K8s)",
    color: "#6366F1",
    tagline: "Friday: Cluster up. Saturday: Deploy your API on K8s.",
    why: "EKS control plane costs $75/month. k3s on a cheap VPS gives you the same K8s experience for $5-18/month. CKA doesn't care which distro you use — kubectl is kubectl.",
    friday: [
      "Provision 2-3 small VPS instances (Hetzner: €3.79/month each, or use 2x t3.micro on AWS free tier)",
      "Install k3s: 1 server node + 1-2 agent nodes. Use Terraform to provision, a bash script to bootstrap k3s",
      "Verify: kubectl get nodes, deploy nginx, expose via NodePort, confirm it works",
      "Install Ingress-NGINX via Helm — point your domain to the cluster",
    ],
    saturday: [
      "Write a Helm chart for your Week 1 API: Deployment, Service, Ingress, ConfigMap, Secret",
      "Create values-dev.yaml and values-prod.yaml — different replica counts, resource limits, env vars",
      "Configure HPA: autoscale based on CPU (set low threshold so you can trigger it easily for demos)",
      "Break it: kill a node (watch pods reschedule), set memory limit to 10Mi (watch OOMKilled), scale to 0 and back",
      "Run 'kubectl top pods', 'kubectl describe pod', 'kubectl logs -f' — these are your new best friends",
    ],
    weeknights: {
      saa: "Section 24 (CloudWatch, CloudTrail, Config — 19 lectures, 1hr 15min) + Section 25 (IAM Advanced — 11 lectures, 49min). ~2hr total.",
      schedule: "Mon/Tue/Wed — Section 24 (monitoring directly relevant to Week 5 project). Thu/Fri — Section 25 (IAM). These topics reinforce each other — you'll configure IAM and CloudWatch in your Terraform soon.",
    },
    cost: "💰 Hetzner route: ~€12/month for 3 nodes (keep running — this is your lab). AWS route: free tier t3.micro but limited. Recommend Hetzner — it's ~$13/month and worth every cent.",
    output: "Add to 'containerised-api-platform' repo: /k8s directory with Helm charts + bootstrap scripts",
    linkedin: {
      post: "Deployed a Kubernetes cluster for $13/month — here's why you don't need EKS to learn K8s",
      angle: "Cost comparison: EKS ($75+) vs k3s on Hetzner ($13). Show kubectl output. This hooks budget-conscious engineers AND hiring managers who value resourcefulness.",
    },
  },
  {
    week: 4,
    phase: "AUTOMATION",
    title: "CI/CD Pipeline + GitHub Actions",
    color: "#F59E0B",
    tagline: "Friday: Pipeline. Saturday: GitOps with ArgoCD.",
    why: "This ties Weeks 1-3 together. Code push → tests → build → deploy. Every interviewer asks about your CI/CD experience.",
    friday: [
      "Build GitHub Actions workflow: lint (ruff) → test (pytest) → Docker build → push to GHCR",
      "Add branch protection: PRs require CI to pass before merge",
      "Configure build caching (Docker layer cache) to speed up builds",
      "Test it: push a PR with a failing test — watch CI block the merge. Push a fix — watch it go green.",
    ],
    saturday: [
      "Install ArgoCD on your k3s cluster via Helm",
      "Create a GitOps repo with Kustomize overlays: base/ + overlays/dev/ + overlays/prod/",
      "Point ArgoCD at the repo — watch it sync your app automatically on git push",
      "Break it: push a bad image tag (watch ArgoCD detect failed health check), manually kubectl edit something (watch ArgoCD correct the drift)",
      "Add Discord/Slack webhook notifications on pipeline failure",
    ],
    weeknights: {
      saa: "Section 26 (Security & Encryption — KMS, SSM, Shield, WAF — 22 lectures, 1hr 25min). This is heavy but critical.",
      schedule: "Mon-Fri — 17 min per night. Focus on KMS (encryption at rest/transit), SSM Parameter Store (you'll use this for secrets), and WAF (relevant to your Week 7 serverless project). Shield/Macie/GuardDuty are memorization — flashcards.",
    },
    cost: "💰 $0 additional — GitHub Actions is free for public repos (2000 min/month). ArgoCD runs on your existing cluster.",
    output: "GitOps repo: 'infra-gitops' with Kustomize overlays + ArgoCD configs. CI/CD in main app repo.",
    linkedin: {
      post: "From git push to production in 4 minutes — here's my entire pipeline",
      angle: "Diagram the pipeline stages. Mention ArgoCD auto-sync and drift detection. The rollback capability is the hook — senior engineers will respect this.",
    },
  },
  {
    week: 5,
    phase: "AUTOMATION",
    title: "Monitoring Stack + Observability",
    color: "#F59E0B",
    tagline: "Friday: Prometheus + Grafana. Saturday: Alerts + dashboards.",
    why: "Observability separates 'I deployed it' from 'I run it in production.' This is what on-call looks like, and it's the #1 gap in junior cloud engineer portfolios.",
    friday: [
      "Deploy kube-prometheus-stack via Helm on your k3s cluster (Prometheus + Grafana + AlertManager in one chart)",
      "Expose Grafana via Ingress — secure with basic auth or your domain",
      "Import pre-built dashboards: K8s cluster health, node resources, pod metrics",
      "Deploy Loki + Promtail for log aggregation — query your API logs from Grafana",
    ],
    saturday: [
      "Build a custom Grafana dashboard for your API: request rate, error rate (5xx), p95 latency, active connections",
      "Configure AlertManager rules: high CPU (>80% for 5min), pod restarts (>3 in 10min), 5xx spike (>5% of traffic)",
      "Route alerts to Discord/Slack webhook",
      "Generate load with 'hey' or k6 — watch dashboards light up. Write a PromQL query that catches your slowest endpoint.",
      "Break it: introduce a memory leak (infinite list append), watch Prometheus catch it before OOM",
    ],
    weeknights: {
      saa: "Section 28 (Disaster Recovery — 12 lectures, 44min) + Section 29 (More Architectures — 6 lectures, 27min) + Section 30 (Other Services — 16 lectures, 48min). ~2hr total.",
      schedule: "Mon/Tue — DR & Migrations (RPO/RTO, pilot light, warm standby — pure memorization). Wed/Thu — Architecture patterns. Fri — Other Services (quick wins, mostly memorization). You're in the home stretch of the course.",
    },
    cost: "💰 $0 additional — runs on your existing k3s cluster. Prometheus/Grafana/Loki are all open source.",
    output: "Add /monitoring directory to k8s repo. Screenshot dashboards for README. Export Grafana dashboard JSON.",
    linkedin: {
      post: "Built a full observability stack for my home lab — here's what my production dashboard looks like",
      angle: "Screenshot your Grafana dashboard. Explain what each panel watches and WHY you chose those metrics. Mention alert fatigue and how you tuned thresholds. Senior-level content from a home lab.",
    },
  },
  {
    week: 6,
    phase: "CERT",
    title: "SAA-C03 Exam Blitz",
    color: "#EF4444",
    tagline: "Friday: Practice exams. Saturday: Weak-area deep dive. SCHEDULE YOUR EXAM FOR NEXT WEEKEND.",
    why: "You've now finished the course content and built real infrastructure using most of the services. This week is pure exam prep. No new projects — just cert grind.",
    friday: [
      "Take Tutorials Dojo Practice Exam #1 (timed, exam conditions). Score yourself honestly.",
      "Review EVERY wrong answer — don't just read the explanation, understand WHY the right answer is right and WHY yours was wrong",
      "Take Practice Exam #2 in the afternoon. Compare scores.",
      "Make a 'weak topics' list from both exams — this is your Saturday study plan",
    ],
    saturday: [
      "Deep-dive your weak topics: re-watch Maarek lectures for those sections + read AWS docs",
      "Take Practice Exam #3 (aim for 75%+ consistently before booking the real exam)",
      "Review the AWS Well-Architected Framework whitepaper (skim — focus on pillars and key concepts)",
      "SCHEDULE YOUR EXAM: book it for next Friday or Saturday. Having a date creates urgency.",
      "If scoring below 70%: don't panic. Take 2 more practice exams this week during evenings.",
    ],
    weeknights: {
      saa: "Section 31 (Whitepapers — 5 lectures, 15min) + Section 32 (Exam Prep — 9 lectures, 17min) + Practice exam review.",
      schedule: "Mon/Tue — Finish remaining course sections (32 min total). Wed/Thu/Fri — One practice exam per evening (or review weak areas). You should be taking 4-6 practice exams total before the real thing.",
    },
    cost: "💰 SAA exam: $150 USD. Tutorials Dojo practice exams: ~$15. Budget for this — it's the highest-ROI spend of the entire plan.",
    output: "Exam scheduled. Practice exam scores logged. Weak-topic notes written.",
    linkedin: {
      post: "Exam booked. Here's how I studied for AWS SAA while building real infrastructure.",
      angle: "Share your study method: build-then-study approach. Mention specific topics that clicked because you'd just built them (VPC, IAM, CloudWatch). This is genuinely useful content for other cert seekers.",
    },
  },
  {
    week: 7,
    phase: "CERT",
    title: "SAA-C03 EXAM WEEK + Serverless Project Start",
    color: "#EF4444",
    tagline: "Friday: TAKE THE EXAM. Saturday: Start your serverless project to decompress.",
    why: "Get the cert done. Then immediately channel that energy into a serverless project — a completely different architecture pattern that broadens your profile.",
    friday: [
      "Morning: light review (no cramming — skim your weak-topic notes, re-read a few Tutorials Dojo explanations)",
      "TAKE THE SAA-C03 EXAM. You've built VPCs, configured IAM, deployed on EC2/EKS, set up CloudWatch. You know this.",
      "After the exam: relax. You earned it. Results are usually instant (pass/fail on screen).",
    ],
    saturday: [
      "Start the Serverless URL Shortener: AWS CDK (TypeScript) + Lambda + API Gateway + DynamoDB",
      "Have AI scaffold the CDK stack — read every construct, understand the L2 constructs vs raw CloudFormation",
      "Implement the core: POST /shorten (create short URL) + GET /:code (redirect to original)",
      "DynamoDB single-table design: PK=shortCode, attributes=longUrl, createdAt, clickCount",
      "Deploy to your AWS account: cdk deploy. Test with curl. Celebrate.",
    ],
    weeknights: {
      saa: "DONE (if you passed). If you didn't pass: review results, identify gaps, reschedule for 2 weeks out. No shame — many people need 2 attempts.",
      schedule: "Mon-Wed: Add features to URL shortener (custom aliases, expiration, click analytics). Thu/Fri: Add WAF rate limiting + CloudWatch alarms + custom domain (mecodes.live/s).",
    },
    cost: "💰 Serverless stays well within free tier: Lambda (1M free requests/month), DynamoDB (25GB free), API Gateway (1M free calls/month). Real cost: ~$0.50/month even with moderate traffic.",
    output: "AWS SAA-C03 CERTIFIED 🎉 + GitHub repo: 'serverless-url-shortener' with CDK code + architecture diagram",
    linkedin: {
      post: "Passed AWS SAA-C03! Here's what I built along the way (and my honest study tips).",
      angle: "This is your highest-engagement post. Share the cert badge, link to your GitHub repos, list what you built. Be honest about what was hard. Tag AWS and Stephane Maarek. People love cert success stories with substance behind them.",
    },
  },
  {
    week: 8,
    phase: "CAPSTONE",
    title: "k8s-platform-bootstrap (The Showpiece Repo)",
    color: "#10B981",
    tagline: "Friday: EKS cluster + ArgoCD + TLS. Saturday: Prometheus + namespace isolation + README.",
    why: "This is the repo that makes hiring managers stop scrolling. A one-command production-grade K8s platform. It synthesises everything you've built so far into a reusable open-source tool.",
    friday: [
      "Terraform EKS cluster: managed node groups (t3.medium spot instances to cut costs by 60-70%)",
      "Bootstrap ArgoCD via Helm as part of the Terraform apply (app-of-apps pattern)",
      "Install Cert-Manager + configure Let's Encrypt ClusterIssuer for automatic TLS",
      "Deploy Ingress-NGINX with the AWS NLB integration",
      "Target: 'terraform apply' brings up a fully functional cluster with GitOps + TLS in one command",
    ],
    saturday: [
      "Deploy kube-prometheus-stack via ArgoCD (not manually — GitOps all the way)",
      "Configure namespace isolation: dev/staging/prod namespaces with NetworkPolicies and ResourceQuotas",
      "Write a comprehensive README: architecture diagram, quick start guide, cost breakdown, design decisions",
      "Record a terminal demo: 'terraform apply' → wait → 'kubectl get pods -A' showing everything running",
      "Break it: delete ArgoCD — watch Terraform recreate it. Delete a namespace — watch ArgoCD restore it.",
    ],
    weeknights: {
      saa: "N/A — cert is done",
      schedule: "Mon-Wed: Polish the repo. Add a GitHub Actions workflow that validates Terraform (fmt, validate, plan). Thu/Fri: Write a detailed blog post / README section on architecture decisions (why EKS vs k3s for production, why ArgoCD, why spot instances).",
    },
    cost: "💰 EKS: $0.10/hr control plane + spot instances (~$0.01-0.03/hr per node). Run it for the weekend: ~$8-12. DESTROY saturday NIGHT. You can always bring it back in 12 minutes.",
    output: "GitHub repo: 'k8s-platform-bootstrap' — the crown jewel. Terraform + Helm + ArgoCD + monitoring. One command.",
    linkedin: {
      post: "I built a production-grade Kubernetes platform that deploys in 12 minutes from a single command — and open-sourced it",
      angle: "This is your second-biggest post. Demo video or terminal recording. Architecture diagram. Cost breakdown (spot instances angle). Open-source it. Share the repo link. Tag Kubernetes and CNCF accounts.",
    },
  },
  {
    week: 9,
    phase: "CAPSTONE",
    title: "Containerised API Platform (Production Polish)",
    color: "#10B981",
    tagline: "Friday: Expand to 3 APIs on k3s. Saturday: Full pipeline + docs.",
    why: "This transforms your Week 1-5 work into a portfolio-ready platform. 3 real APIs, Helm charts, CI/CD, monitoring — all on your $13/month k3s cluster. Shows you can run production infra cheaply.",
    friday: [
      "Add 2 more APIs to your platform: a simple auth service (JWT) + a webhook receiver/forwarder",
      "Each service gets its own Helm chart, Docker image, and GitHub Actions pipeline",
      "Configure service-to-service communication within the cluster (ClusterIP services, internal DNS)",
      "Set up a shared PostgreSQL instance with per-service databases (or separate instances if resources allow)",
    ],
    saturday: [
      "Verify full pipeline for all 3 services: push code → CI → GHCR → ArgoCD → k3s → monitored",
      "Update Grafana dashboards to show all 3 services side by side",
      "Write architecture docs: how services communicate, how deploys work, how monitoring is configured",
      "Calculate and document monthly cost: 'I run 3 production APIs with full CI/CD and monitoring for $18/month'",
      "Update README with architecture diagram showing the full platform",
    ],
    weeknights: {
      saa: "N/A",
      schedule: "Mon-Wed: Bug fixes, edge cases, error handling. Thu/Fri: Start CKA study — Killer.sh practice environment (comes free with CKA exam registration). Your cluster experience makes CKA labs feel natural now.",
    },
    cost: "💰 Same $13/month Hetzner cluster. No additional cost. The '$18/month production platform' is a selling point.",
    output: "Polished 'containerised-api-platform' repo: 3 services, Helm charts, CI/CD, monitoring, full docs",
    linkedin: {
      post: "I run 3 production APIs with CI/CD, GitOps, and full observability for $18/month. Here's the entire stack.",
      angle: "Cost is the hook. Architecture diagram showing the full platform. Link to the repo. This resonates with startup CTOs and engineering managers who care about efficiency.",
    },
  },
  {
    week: 10,
    phase: "LAUNCH",
    title: "Portfolio Polish + Application Blitz",
    color: "#D946EF",
    tagline: "Friday: Portfolio site + GitHub cleanup. Saturday: Start applying.",
    why: "You now have 4-5 repos, a cert, and 9 LinkedIn posts. This week converts all of it into job interviews.",
    friday: [
      "Deploy a portfolio site on your k3s cluster (simple Next.js or even static HTML — substance over style)",
      "Each project gets: architecture diagram, tech stack, key decisions, lessons learned, live links where applicable",
      "Clean up ALL GitHub repos: consistent READMEs, remove dead code, add LICENSE files, pin important repos",
      "Update your CV (use the 2 versions we already made) with real project details replacing placeholder content",
    ],
    saturday: [
      "Update LinkedIn: headline, about section, experience (add projects as experience entries), featured section with top posts",
      "Write the capstone LinkedIn post: '10 weeks ago I had zero cloud projects. Here's everything I built.'",
      "Start applying: 5 targeted applications today. Customise each cover letter / intro message.",
      "Target list: remote EU companies (Germany, Netherlands, UK), Gulf startups (Dubai, Riyadh, Qatar), US remote-EMEA roles",
      "Set up job alerts on LinkedIn, AngelList/Wellfound, RemoteOK, WeWorkRemotely, Relocate.me",
    ],
    weeknights: {
      saa: "N/A",
      schedule: "Mon-Fri: 5 applications per night = 25/week. Weeknights are now APPLICATION TIME. Keep a spreadsheet tracking every application, status, and follow-up dates. Also: 15 min/night mock interviews with AI voice chat.",
    },
    cost: "💰 $0 additional. Your existing infra hosts the portfolio.",
    output: "Live portfolio site. Updated CVs. 5+ job applications submitted. LinkedIn fully optimised.",
    linkedin: {
      post: "10 weeks ago I had zero cloud projects. Here's everything I built, what I learned, and I'm now open to work.",
      angle: "Pin this post. Link every repo. Share cert badge. Be specific about what roles you want and where. Engage with EVERY comment. This is your launch post.",
    },
  },
];

const BUFFER_NOTE = {
  title: "Buffer Weeks (Built into the plan)",
  items: [
    "If a weekend goes badly (sick, family, burnout), push that week's work to the following weekend. The plan survives 2-3 slips.",
    "Weeks 1-5 are sequential (each builds on the last). Weeks 7-9 are more independent — you can reorder if needed.",
    "If SAA exam needs to move: shift Weeks 7+ back accordingly. The cert matters more than the project timeline.",
    "If you're ahead of schedule: start CKA prep earlier. CKA + SAA is the combo that gets interviews.",
    "Real timeline: plan says 10 weeks, expect 12-14 with life getting in the way. That's still fast.",
  ]
};

const COST_SUMMARY = {
  title: "Total Cost Breakdown",
  items: [
    { label: "Hetzner k3s cluster (3 nodes, months 3-10)", value: "~$90" },
    { label: "AWS free tier usage (Weeks 2-8)", value: "~$15-30" },
    { label: "EKS weekend (Week 8 only, destroy after)", value: "~$10" },
    { label: "SAA-C03 exam fee", value: "$150" },
    { label: "Tutorials Dojo practice exams", value: "$15" },
    { label: "Domain (if not already owned)", value: "$10-15/yr" },
    { label: "TOTAL (10 weeks)", value: "~$300 USD" },
  ]
};

const PHASE_COLORS = {
  CONTAINERS: { bg: "#EFF6FF", border: "#0EA5E9", text: "#0369A1" },
  INFRASTRUCTURE: { bg: "#EEF2FF", border: "#6366F1", text: "#4338CA" },
  AUTOMATION: { bg: "#FFFBEB", border: "#F59E0B", text: "#B45309" },
  CERT: { bg: "#FEF2F2", border: "#EF4444", text: "#B91C1C" },
  CAPSTONE: { bg: "#ECFDF5", border: "#10B981", text: "#047857" },
  LAUNCH: { bg: "#FDF4FF", border: "#D946EF", text: "#A21CAF" },
};

export default function Roadmap() {
  const [activeWeek, setActiveWeek] = useState(0);
  const [expandedSections, setExpandedSections] = useState({
    friday: true, saturday: false, weeknights: false, meta: false
  });

  const w = WEEKS[activeWeek];
  const pc = PHASE_COLORS[w.phase];

  const toggleSection = (key) => {
    setExpandedSections(prev => ({ ...prev, [key]: !prev[key] }));
  };

  const Section = ({ title, sectionKey, icon, children }) => (
    <div style={{ marginBottom: 10 }}>
      <button
        onClick={() => toggleSection(sectionKey)}
        style={{
          width: "100%", display: "flex", alignItems: "center", justifyContent: "space-between",
          padding: "10px 14px", background: expandedSections[sectionKey] ? pc.bg : "#F9FAFB",
          border: `1px solid ${expandedSections[sectionKey] ? pc.border : "#E5E7EB"}`,
          borderRadius: 8, cursor: "pointer", transition: "all 0.2s",
          fontFamily: "'JetBrains Mono', monospace"
        }}
      >
        <span style={{ fontSize: 13, fontWeight: 600, color: expandedSections[sectionKey] ? pc.text : "#374151" }}>
          {icon} {title}
        </span>
        <span style={{ fontSize: 12, color: "#9CA3AF", transform: expandedSections[sectionKey] ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>▼</span>
      </button>
      {expandedSections[sectionKey] && (
        <div style={{ padding: "12px 14px", borderLeft: `2px solid ${pc.border}`, marginLeft: 16, marginTop: 4 }}>
          {children}
        </div>
      )}
    </div>
  );

  const BulletList = ({ items }) => (
    <div style={{ display: "flex", flexDirection: "column", gap: 7 }}>
      {items.map((item, i) => (
        <div key={i} style={{ display: "flex", gap: 8, fontSize: 12.5, color: "#374151", lineHeight: 1.55, fontFamily: "'IBM Plex Sans', sans-serif" }}>
          <span style={{ color: pc.border, fontWeight: 700, flexShrink: 0 }}>→</span>
          <span>{item}</span>
        </div>
      ))}
    </div>
  );

  return (
    <div style={{
      maxWidth: 780, margin: "0 auto", padding: "20px 16px",
      fontFamily: "'IBM Plex Sans', sans-serif",
      background: "#FFFFFF", minHeight: "100vh"
    }}>
      <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet" />

      {/* Header */}
      <div style={{ marginBottom: 28, borderBottom: "2px solid #111827", paddingBottom: 16 }}>
        <h1 style={{ fontSize: 24, fontWeight: 700, color: "#111827", margin: 0, fontFamily: "'JetBrains Mono', monospace", letterSpacing: -0.5 }}>
          10-WEEK WEEKEND BATTLE PLAN
        </h1>
        <p style={{ fontSize: 13, color: "#6B7280", margin: "6px 0 0", lineHeight: 1.5 }}>
          Weekends build. Weeknights study. SAA exam Week 7. Applications Week 10.
          <span style={{ color: "#111827", fontWeight: 600 }}> Every weekend ships something real.</span>
        </p>
        <div style={{ display: "flex", gap: 12, marginTop: 10, flexWrap: "wrap" }}>
          {Object.entries(PHASE_COLORS).map(([phase, colors]) => (
            <span key={phase} style={{
              fontSize: 10, fontWeight: 600, padding: "2px 8px", borderRadius: 4,
              background: colors.bg, color: colors.text, border: `1px solid ${colors.border}`,
              fontFamily: "'JetBrains Mono', monospace",
            }}>
              {phase}
            </span>
          ))}
        </div>
      </div>

      {/* Week Selector */}
      <div style={{ display: "flex", gap: 5, marginBottom: 20, flexWrap: "wrap" }}>
        {WEEKS.map((week, i) => (
          <button
            key={i}
            onClick={() => { setActiveWeek(i); setExpandedSections({ friday: true, saturday: false, weeknights: false, meta: false }); }}
            style={{
              padding: "6px 11px",
              border: activeWeek === i ? `2px solid ${week.color}` : "1px solid #E5E7EB",
              borderRadius: 6,
              background: activeWeek === i ? PHASE_COLORS[week.phase].bg : "#FFF",
              cursor: "pointer",
              fontSize: 11,
              fontWeight: activeWeek === i ? 700 : 500,
              color: activeWeek === i ? week.color : "#6B7280",
              fontFamily: "'JetBrains Mono', monospace",
              transition: "all 0.15s",
            }}
          >
            W{week.week}
          </button>
        ))}
      </div>

      {/* Active Week Card */}
      <div style={{ border: `2px solid ${pc.border}`, borderRadius: 12, overflow: "hidden", marginBottom: 20 }}>
        <div style={{ background: pc.bg, padding: "14px 18px", borderBottom: `1px solid ${pc.border}` }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 4 }}>
            <span style={{
              background: pc.border, color: "#FFF", fontSize: 10, fontWeight: 700,
              padding: "2px 8px", borderRadius: 4, fontFamily: "'JetBrains Mono', monospace",
            }}>
              WEEK {w.week} — {w.phase}
            </span>
          </div>
          <h2 style={{ fontSize: 18, fontWeight: 700, color: "#111827", margin: "4px 0 2px", fontFamily: "'JetBrains Mono', monospace" }}>
            {w.title}
          </h2>
          <p style={{ fontSize: 12, color: pc.text, margin: "2px 0 0", fontWeight: 600, fontFamily: "'JetBrains Mono', monospace" }}>
            {w.tagline}
          </p>
          <p style={{ fontSize: 12.5, color: "#4B5563", margin: "8px 0 0", lineHeight: 1.5, fontStyle: "italic" }}>
            {w.why}
          </p>
        </div>

        <div style={{ padding: 14 }}>
          <Section title="Friday" sectionKey="friday" icon="🔨">
            <BulletList items={w.friday} />
          </Section>

          <Section title="Saturday" sectionKey="saturday" icon="🚀">
            <BulletList items={w.saturday} />
          </Section>

          <Section title="Weeknight Study (Mon-Fri)" sectionKey="weeknights" icon="📚">
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              <div>
                <div style={{ fontSize: 11, fontWeight: 700, color: pc.text, fontFamily: "'JetBrains Mono', monospace", marginBottom: 4 }}>
                  SAA-C03 COURSE
                </div>
                <p style={{ fontSize: 12.5, color: "#374151", lineHeight: 1.55, margin: 0 }}>{w.weeknights.saa}</p>
              </div>
              <div>
                <div style={{ fontSize: 11, fontWeight: 700, color: pc.text, fontFamily: "'JetBrains Mono', monospace", marginBottom: 4 }}>
                  SCHEDULE
                </div>
                <p style={{ fontSize: 12.5, color: "#374151", lineHeight: 1.55, margin: 0 }}>{w.weeknights.schedule}</p>
              </div>
            </div>
          </Section>

          <Section title="Cost + Output + LinkedIn" sectionKey="meta" icon="📋">
            <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
              <div style={{ fontSize: 12.5, color: "#374151", lineHeight: 1.5 }}>
                <strong style={{ color: pc.text }}>Cost:</strong> {w.cost}
              </div>
              <div style={{ fontSize: 12.5, color: "#374151", lineHeight: 1.5 }}>
                <strong style={{ color: pc.text }}>Output:</strong> {w.output}
              </div>
              <div style={{
                background: "#F3F4F6", padding: "10px 12px", borderRadius: 6, marginTop: 4,
              }}>
                <div style={{ fontSize: 11, fontWeight: 700, color: pc.text, fontFamily: "'JetBrains Mono', monospace", marginBottom: 4 }}>
                  LINKEDIN POST
                </div>
                <p style={{ fontSize: 13, fontWeight: 600, color: "#111827", margin: "0 0 6px" }}>
                  "{w.linkedin.post}"
                </p>
                <p style={{ fontSize: 12, color: "#4B5563", lineHeight: 1.5, margin: 0 }}>
                  {w.linkedin.angle}
                </p>
              </div>
            </div>
          </Section>
        </div>
      </div>

      {/* Cost Summary */}
      <div style={{
        border: "1px solid #E5E7EB", borderRadius: 10, padding: 16, marginBottom: 16,
        background: "#FAFAFA"
      }}>
        <h3 style={{ fontSize: 14, fontWeight: 700, color: "#111827", margin: "0 0 12px", fontFamily: "'JetBrains Mono', monospace" }}>
          💰 {COST_SUMMARY.title}
        </h3>
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {COST_SUMMARY.items.map((item, i) => (
            <div key={i} style={{
              display: "flex", justifyContent: "space-between", alignItems: "center",
              fontSize: 12.5, color: i === COST_SUMMARY.items.length - 1 ? "#111827" : "#4B5563",
              fontWeight: i === COST_SUMMARY.items.length - 1 ? 700 : 400,
              borderTop: i === COST_SUMMARY.items.length - 1 ? "1px solid #D1D5DB" : "none",
              paddingTop: i === COST_SUMMARY.items.length - 1 ? 6 : 0,
            }}>
              <span>{item.label}</span>
              <span style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12 }}>{item.value}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Buffer Notes */}
      <div style={{
        border: "1px solid #E5E7EB", borderRadius: 10, padding: 16, marginBottom: 16,
        background: "#FAFAFA"
      }}>
        <h3 style={{ fontSize: 14, fontWeight: 700, color: "#111827", margin: "0 0 12px", fontFamily: "'JetBrains Mono', monospace" }}>
          🛡️ {BUFFER_NOTE.title}
        </h3>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {BUFFER_NOTE.items.map((item, i) => (
            <div key={i} style={{ display: "flex", gap: 8, fontSize: 12.5, color: "#4B5563", lineHeight: 1.5 }}>
              <span style={{ color: "#9CA3AF", fontWeight: 700, flexShrink: 0 }}>—</span>
              <span>{item}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Rules */}
      <div style={{ border: "2px solid #111827", borderRadius: 10, padding: 16, background: "#111827" }}>
        <h3 style={{ fontSize: 14, fontWeight: 700, color: "#F9FAFB", margin: "0 0 12px", fontFamily: "'JetBrains Mono', monospace" }}>
          THE RULES
        </h3>
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {[
            "AI scaffolds. You break it, fix it, explain it out loud. That's the loop.",
            "terraform destroy every Saturday night. Rebuild next Friday in minutes. No surprise bills.",
            "Post on LinkedIn every weekend. No excuses. Consistency compounds.",
            "Every repo: README + architecture diagram or it doesn't count.",
            "15 min mock interviews with AI after each weekend. If you can't explain it, break it again.",
            "Weeknights = SAA study (Weeks 1-7) then job applications (Weeks 8+). Protect this time.",
            "GitHub commits every weekend. The green squares graph is your proof of work.",
            "Target: remote EU, Gulf startups (Dubai/Riyadh), US companies hiring EMEA timezone.",
          ].map((rule, i) => (
            <div key={i} style={{ display: "flex", gap: 8, fontSize: 12.5, color: "#D1D5DB", lineHeight: 1.5 }}>
              <span style={{ color: "#F59E0B", fontWeight: 700, fontFamily: "'JetBrains Mono', monospace", flexShrink: 0 }}>
                {String(i + 1).padStart(2, '0')}
              </span>
              <span>{rule}</span>
            </div>
          ))}
        </div>
      </div>

      <div style={{ textAlign: "center", marginTop: 20, fontSize: 11, color: "#9CA3AF", fontFamily: "'JetBrains Mono', monospace" }}>
        10 weekends. 5 repos. 1 cert. 10 LinkedIn posts. ~$300 total. Your ticket out.
      </div>
    </div>
  );
}
